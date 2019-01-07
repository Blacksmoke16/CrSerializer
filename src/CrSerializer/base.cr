require "./validator"
require "./assertions/*"
require "json"
require "yaml"
require "semantic_version"

# :nodoc:
class Array(T)
  def serialize(groups : Array(String) = ["default"]) : String
    io = IO::Memory.new
    builder = ::JSON::Builder.new io
    builder.document do
      builder.array do
        self.each do |obj|
          obj.to_json(builder, groups)
        end
      end
      io.to_s
    end
  end

  def self.deserialize(string_or_io) : Array(T)
    Array(T).from_json string_or_io
  end
end

# Override `Object#to_json` to allow for the two params
# :nodoc:
class Object
  def to_json(json : ::JSON::Builder, groups : Array(String) = ["default"])
    to_json json
  end

  def self.deserialize(json : String) : self
    from_json json
  end
end

module CrSerializer
  include JSON::Serializable
  include CrSerializer::Assertions

  @[CrSerializer::Options(expose: false)]
  @[JSON::Field(ignore: true)]
  @[YAML::Field(ignore: true)]
  # See `Validator`
  getter validator : CrSerializer::Validator = CrSerializer::Validator.new

  macro included
    # Deserializes a JSON string into an object
    def self.deserialize(json_string : String) : self
      from_json(json_string)
    end
  end

  # Rerun all assertions on the current state of the object
  def validate : Nil
    assertions = [] of CrSerializer::Assertions::Assertion
    {% for ivar in @type.instance_vars %}
      {% for t, v in CrSerializer::Assertions::ASSERTIONS %}
        {% ann = ivar.annotation(t.resolve) %}
        {% if ann %}
          {% v = v.expressions[0] if v.is_a?(Expressions) %}
          assertions << {{t.resolve.name.split("::").last.id}}Assertion({{ivar.type.stringify.id}}).new({{ivar.stringify}},{{ann[:message]}},{{ivar.id}},{{v.select { |fi| ann[fi] != nil }.map { |f| %(#{f.id}: #{ann[f]}#{f == :choices ? " of CrSerializer::Assertions::ALLDATATYPES".id : "".id}) }.join(',').id}})
        {% end %}
      {% end %}
    {% end %}
    @validator = CrSerializer::Validator.new assertions
  end

  # :nodoc:
  def after_initialize : self
    # Deserialization options
    {% begin %}
      {% for ivar in @type.instance_vars %}
        {% ann = ivar.annotation(CrSerializer::Options) %}
        {% if ann && ann[:readonly] == true %}
          self.{{ivar.id}} = {{ivar.default_value}}
        {% end %}
      {% end %}

      # Validations
      {% cann = @type.annotation(CrSerializer::ClassOptions) %}
      {% if !cann || cann[:validate] == true || cann[:validate] == nil %}
        validate
      {% end %}
      {% if cann && cann[:raise_on_invalid] == true %}
        raise CrSerializer::Exceptions::ValidationException.new @validator unless @validator.valid?
      {% end %}
    {% end %}
    self
  end

  # Serializes the object to JSON
  #
  # Optionally accepts an array of groups that should be serialized
  def serialize(groups : Array(String) = ["default"]) : String
    io = IO::Memory.new
    builder = ::JSON::Builder.new io
    builder.document do
      to_json(builder, groups)
    end
    io.to_s
  end
end

# :nodoc:
module JSON::Serializable
  def to_json(json : ::JSON::Builder, groups : Array(String) = ["default"])
    {% begin %}
      {% properties = {} of Nil => Nil %}
      {% cann = @type.annotation(CrSerializer::ClassOptions) %}
      {% for ivar in @type.instance_vars %}
        {% cr_ann = ivar.annotation(CrSerializer::Options) %}
        {% json_ann = ivar.annotation(JSON::Field) %}
        {% unless (cann && cann[:exclusion_policy].resolve == CrSerializer::ExclusionPolicy::EXCLUDE_ALL) && (!cr_ann || cr_ann[:expose] != true) %}
          {% if (!cr_ann || (cr_ann && (cr_ann[:expose] == true || cr_ann[:expose] == nil))) && (!json_ann || (json_ann && (json_ann[:ignore] == false || json_ann[:ignore] == nil))) %}
            {%
              properties[ivar.id] = {
                key:       ((cr_ann && cr_ann[:serialized_name]) || ivar).id.stringify,
                emit_null: (cr_ann && cr_ann[:emit_null] == true) ? true : false,
                value:     (cr_ann && cr_ann[:accessor]) ? cr_ann[:accessor] : ivar.id,
                since:     (cr_ann && cr_ann[:since]) ? cr_ann[:since] : nil,
                until:     (cr_ann && cr_ann[:until]) ? cr_ann[:until] : nil,
                groups:    (cr_ann && cr_ann[:groups]) ? cr_ann[:groups] : ["default"],
              }
            %}
          {% end %}
        {% end %}
      {% end %}

        json.object do
          {% for name, value in properties %}
            _{{name}} = {{value[:value]}}

            {% unless value[:emit_null] %} unless _{{name}}.nil?  {% end %}
              {% if value[:since] != nil || value[:until] != nil %}
                if !CrSerializer.version.nil? && SemanticVersion.parse(CrSerializer.version.not_nil!) {% if value[:since] %} >= (SemanticVersion.parse({{value[:since]}})) {% else %} < (SemanticVersion.parse({{value[:until]}})) {% end %}
              {% end %}

              if {{value[:groups]}}.any? { |g| groups.includes? g}

                json.field({{value[:key]}}) do
                  if _{{name}}.responds_to? :serialize
                    _{{name}}.to_json(json, groups)
                  else
                    _{{name}}.to_json(json)
                  end
                end

              end

              {% if value[:since] != nil || value[:until] != nil %}
                end
              {% end %}

            {% unless value[:emit_null] %} end {% end %}
          {% end %}
          on_to_json(json)
        end
      {% end %}
  end
end
