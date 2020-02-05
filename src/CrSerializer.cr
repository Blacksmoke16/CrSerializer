require "json"
require "yaml"
require "semantic_version"

# Can be included into a module to register that
# module as a serialization format.
#
# The including module would have to implement the required logic
# for handling the process of serializing and deserializing the data.
# ```
# module CustomFormat
#   include CrSerializer::Format
# end
#
# some_obj.serialize CustomFormat
# SomeType.deserialize CustomFormat, input_string_or_io
# ```
module CrSerializer::Format
end

require "./exceptions/*"
require "./exclusion_strategies/*"
require "./annotations"
require "./deserialization_context"
require "./serialization_context"
require "./property_metadata"
require "./exclusion_policy"
require "./formats/*"

# Shorthand alias to the `CrSerializer::Annotations` module.
#
# ```
# @[CRS::Expose]
# @[CRS::Groups("detail", "list")]
# property title : String
# ```
alias CRS = CrSerializer::Annotations

# Annotation based serialization/deserialization library.
#
# ## Features
# * Options are defined on ivars, no custom DSL.
# * Can be used in conjunction with other shards, such as ORMs, as long as they use properties and allow adding annotations.
# * `*::Serializable` compatible API.
#
# ## Concepts
# * `CrSerializer::Annotations` - Used to control how a property gets serialized/deserialized.
# * `CrSerializer::ExclusionStrategies` - Determines which properties within a class/struct should be serialized and deserialized.  Custom strategies can be defined.
# * `CrSerializer::Context` - Represents runtime data about the current serialization/deserialization action.  Can be reopened to add custom data.
# * `CrSerializer::Format` - Represents a valid serialization/deserialization format.  Can be included into a module to register a custom format.
#
# ## Example Usage
# ```
# @[CRS::ExclusionPolicy(:all)]
# @[CRS::AccessorOrder(:alphabetical)]
# class Example
#   include CrSerializer
#
#   @[CRS::Expose]
#   @[CRS::Groups("details")]
#   property name : String
#
#   @[CRS::Expose]
#   @[CRS::Name(deserialize: "a_prop", serialize: "a_prop")]
#   property some_prop : String
#
#   @[CRS::Expose]
#   @[CRS::Groups("default", "details")]
#   @[CRS::Accessor(getter: get_title)]
#   property title : String
#
#   @[CRS::ReadOnly]
#   property password : String?
#
#   getter first_name : String?
#   getter last_name : String?
#
#   @[CRS::PostDeserialize]
#   def split_name : Nil
#     @first_name, @last_name = @name.split(' ')
#   end
#
#   @[CRS::VirtualProperty]
#   def get_val : String
#     "VAL"
#   end
#
#   private def get_title : String
#     @title.downcase
#   end
# end
#
# obj = Example.from_json %({"name":"FIRST LAST","a_prop":"STR","title":"TITLE","password":"monkey123"})
# obj.inspect                                                             # => #<Example:0x7f3e3b106740 @name="FIRST LAST", @some_prop="STR", @title="TITLE", @password=nil, @first_name="FIRST", @last_name="LAST">
# obj.to_json                                                             # => {"a_prop":"STR","get_val":"VAL","name":"FIRST LAST","title":"title"}
# obj.to_json CrSerializer::SerializationContext.new.groups = ["details"] # => {"name":"FIRST LAST","title":"title"}
# ```
module CrSerializer
  macro included
    def self.deserialize(format : CrSerializer::Format.class, string_or_io : String | IO, context : CrSerializer::DeserializationContext = CrSerializer::DeserializationContext.new) : self

      # Initialize the context.  Currently just used to apply default exclusion strategies
      context.init

      properties = self.deserialization_properties

      # Apply exclusion strategies if one is defined
      if strategy = context.exclusion_strategy
        properties.reject! { |property| strategy.skip_property? property, context }
      end

      # Get the serialized output for the set of properties
      obj = format.deserialize \{{@type}}, properties , string_or_io, context

      # Run any post deserialization methods
      \{% for method in @type.methods.select { |m| m.annotation(CRS::PostDeserialize) } %}
        obj.\{{method.name}}
      \{% end %}

      obj
    end

    def self.deserialization_properties : Array(CrSerializer::Metadata)
      {% verbatim do %}
        {% begin %}
          # Construct the array of metadata from the properties on `self`.
          # Takes into consideration some annotations to control how/when a property should be serialized
          {%
            ivars = @type.instance_vars
              .reject { |ivar| ivar.annotation(CRS::Skip) }
              .reject { |ivar| ivar.annotation(CRS::IgnoreOnDeserialize) }
              .reject { |ivar| (ann = ivar.annotation(CRS::ReadOnly)); ann && !ivar.has_default_value? && !ivar.type.nilable? ? raise "#{@type}##{ivar.name} is read-only but is not nilable nor has a default value" : ann }
              .reject do |ivar|
                not_exposed = (ann = @type.annotation(CRS::ExclusionPolicy)) && ann[0] == :all && !ivar.annotation(CRS::Expose)
                excluded = (ann = @type.annotation(CRS::ExclusionPolicy)) && ann[0] == :none && ivar.annotation(CRS::Exclude)

                !ivar.annotation(CRS::IgnoreOnSerialize) && (not_exposed || excluded)
              end
          %}

          {{ivars.map do |ivar|
              %(CrSerializer::PropertyMetadata(#{ivar.type}?, #{@type})
            .new(
              name: #{ivar.name.stringify},
              external_name: #{(ann = ivar.annotation(CRS::Name)) && (name = ann[:deserialize]) ? name : ivar.name.stringify},
              aliases: #{(ann = ivar.annotation(CRS::Name)) && (aliases = ann[:aliases]) ? aliases : "[] of String".id},
              groups: #{(ann = ivar.annotation(CRS::Groups)) && !ann.args.empty? ? [ann.args.splat] : ["default"]},
              since_version: #{(ann = ivar.annotation(CRS::Since)) && !ann[0].nil? ? "SemanticVersion.parse(#{ann[0]})".id : nil},
              until_version: #{(ann = ivar.annotation(CRS::Until)) && !ann[0].nil? ? "SemanticVersion.parse(#{ann[0]})".id : nil},
            )).id
            end}} of CrSerializer::Metadata
        {% end %}
      {% end %}
    end
  end

  # Deserializes the given *string_or_io* into `self` from the given *format*, optionally with the given *context*.
  #
  # NOTE: This method is defined within a macro included hook.  This definition is simply for documentation.
  def self.deserialize(format : CrSerializer::Format.class, string_or_io : String | IO, context : CrSerializer::DeserializationContext = CrSerializer::DeserializationContext.new) : self
  end

  # Serializes `self` into the given *format*, optionally with the given *context*.
  def serialize(format : CrSerializer::Format.class, context : CrSerializer::SerializationContext = CrSerializer::SerializationContext.new) : String
    {% begin %}

      # Initialize the context.  Currently just used to apply default exclusion strategies
      context.init

      # Run any pre serialization methods
      {% for method in @type.methods.select { |m| m.annotation(CRS::PreSerialize) } %}
        {{method.name}}
      {% end %}

      properties = serialization_properties

      # Apply exclusion strategies if one is defined
      if strategy = context.exclusion_strategy
        properties.reject! { |property| strategy.skip_property? property, context }
      end

      # Reject properties that shoud be skipped when empty
      # or properties that should be skipped when nil
      properties.reject! do |property|
        val = property.value
        skip_when_empty = property.skip_when_empty? && val.responds_to? :empty? && val.empty?
        skip_nil = !context.emit_nil? && val.nil?

        skip_when_empty || skip_nil
      end

      # Get the serialized output for the set of properties
      output = format.serialize properties, context

      # Run any post serialization methods
      {% for method in @type.methods.select { |m| m.annotation(CRS::PostSerialize) } %}
        {{method.name}}
      {% end %}

      # Return the serialized data
      output
    {% end %}
  end

  # The `PropertyMetadata` that makes up `self`'s properties.
  protected def serialization_properties : Array(CrSerializer::Metadata)
    {% begin %}
      # Construct the array of metadata from the properties on `self`.
      # Takes into consideration some annotations to control how/when a property should be serialized
          {%
            ivars = @type.instance_vars
              .reject { |ivar| ivar.annotation(CRS::Skip) }
              .reject { |ivar| ivar.annotation(CRS::IgnoreOnSerialize) }
              .reject { |ivar| (ann = ivar.annotation(CRS::ReadOnly)); ann && !ivar.has_default_value? && !ivar.type.nilable? ? raise "#{@type}##{ivar.name} is read-only but is not nilable nor has a default value" : ann }
              .reject do |ivar|
                not_exposed = (ann = @type.annotation(CRS::ExclusionPolicy)) && ann[0] == :all && !ivar.annotation(CRS::Expose)
                excluded = (ann = @type.annotation(CRS::ExclusionPolicy)) && ann[0] == :none && ivar.annotation(CRS::Exclude)

                !ivar.annotation(CRS::IgnoreOnDeserialize) && (not_exposed || excluded)
              end
          %}

      {% property_hash = {} of String => CrSerializer::PropertyMetadata %}

      {% for ivar in ivars %}
        {% external_name = (ann = ivar.annotation(CRS::Name)) && (name = ann[:serialize]) ? name : ivar.name.stringify %}

        {% property_hash[external_name] = %(CrSerializer::PropertyMetadata(
              #{ivar.type},
              #{@type},
            )
            .new(
              name: #{ivar.name.stringify},
              external_name: #{external_name},
              value: #{(accessor = ivar.annotation(CRS::Accessor)) && accessor[:getter] != nil ? accessor[:getter].id : ivar.id},
              skip_when_empty: #{!!ivar.annotation(CRS::SkipWhenEmpty)},
              groups: #{(ann = ivar.annotation(CRS::Groups)) && !ann.args.empty? ? [ann.args.splat] : ["default"]},
              since_version: #{(ann = ivar.annotation(CRS::Since)) && !ann[0].nil? ? "SemanticVersion.parse(#{ann[0]})".id : nil},
              until_version: #{(ann = ivar.annotation(CRS::Until)) && !ann[0].nil? ? "SemanticVersion.parse(#{ann[0]})".id : nil},
            )).id %}
      {% end %}

      {% for method in @type.methods.select { |method| method.annotation(CRS::VirtualProperty) } %}
        {% external_name = (ann = method.annotation(CRS::Name)) && (name = ann[:serialize]) ? name : method.name.stringify %}

        {% property_hash[external_name] = %(CrSerializer::PropertyMetadata(
                #{method.return_type},
                #{@type},
              )
              .new(
                name: #{method.name.stringify},
                external_name: #{external_name},
                value: #{method.name.id},
                skip_when_empty: #{!!method.annotation(CRS::SkipWhenEmpty)},
              )).id %}
      {% end %}

      {% if (ann = @type.annotation(CRS::AccessorOrder)) && !ann[0].nil? %}
        {% if ann[0] == :alphabetical %}
          {% properties = property_hash.keys.sort.map { |key| property_hash[key] } %}
        {% elsif ann[0] == :custom && !ann[:order].nil? %}
          {% raise "Not all properties were defined in the custom order for '#{@type}'" unless property_hash.keys.all? { |prop| ann[:order].map(&.id.stringify).includes? prop } %}
          {% properties = ann[:order].map { |val| property_hash[val.id.stringify] || raise "Unknown instance variable: '#{val.id}'" } %}
        {% else %}
          {% raise "Invalid CRS::AccessorOrder value: '#{ann[0].id}'" %}
        {% end %}
      {% else %}
        {% properties = property_hash.values %}
      {% end %}

      {{properties}} of CrSerializer::Metadata
    {% end %}
  end
end
