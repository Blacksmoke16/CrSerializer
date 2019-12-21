####################################
# Interface methods for the format #
####################################

# :nodoc:
module JSON
  include CrSerializer::Format

  def self.prepare(input : String | IO) : JSON::Any
    JSON.parse input
  end

  def self.discriminator_value(data : JSON::Any, key : String) : String?
    data[key].as_s?
  end

  # Overload for Objects
  def self.deserialize(type : _, properties : Array(CrSerializer::Metadata), data : JSON::Any, context : CrSerializer::DeserializationContext)
    type.new properties, data, context
  end

  # Overload for primitive types
  def self.deserialize(type : _, input : String | IO, context : CrSerializer::DeserializationContext?)
    type.new JSON.parse(input), nil
  rescue ex : TypeCastError
    if (msg = ex.message) && (deserialized_type = msg.match(/^cast from (\w+) to (\w+)/))
      raise CrSerializer::Exceptions::JSONParseError.new "Expected #{type} but was #{deserialized_type[1]}"
    end

    raise ex
  end

  # Overload for Objects
  def self.serialize(properties : Array(CrSerializer::Metadata), context : CrSerializer::SerializationContext) : String
    String.build do |str|
      JSON.build(str) do |builder|
        serialize properties, context, builder
      end
    end
  end

  # Overload for Objects
  def self.serialize(properties : Array(CrSerializer::Metadata), context : CrSerializer::SerializationContext, builder : JSON::Builder) : Nil
    builder.object do
      properties.each do |p|
        builder.field(p.external_name) do
          p.value.serialize builder, context
        end
      end
    end
  end

  # Overload for primitive types
  def self.serialize(obj : _, context : CrSerializer::SerializationContext?) : String
    String.build do |str|
      JSON.build(str) do |builder|
        obj.serialize builder, context
      end
    end
  end
end

####################################################
# Overloads to CrSerializer to support this format #
####################################################

module CrSerializer
  macro included
    def self.from_json(string_or_io : String | IO, context : CrSerializer::DeserializationContext = CrSerializer::DeserializationContext.new)
      deserialize JSON, string_or_io, context
    end

    def self.new(properties : Array(CrSerializer::Metadata), json : JSON::Any, context : CrSerializer::DeserializationContext)
      instance = allocate
      instance.initialize properties, json, context
      GC.add_finalizer(instance) if instance.responds_to?(:finalize)
      instance
    end

    def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext)
      process_deserialization(context) do |properties|
        new properties, json, context
      end
    end

    macro inherited
      def self.new(properties : Array(CrSerializer::Metadata), json : JSON::Any, context : CrSerializer::DeserializationContext)
        super
      end
    end

    def initialize(properties : Array(CrSerializer::Metadata), json : JSON::Any, context : CrSerializer::DeserializationContext)
      {% verbatim do %}
        {% begin %}
          {% for ivar, idx in @type.instance_vars %}
            if (prop = properties.find { |p| p.name == {{ivar.name.stringify}} }) && ((val = json[prop.external_name]?) || ((key = prop.aliases.find { |a| json[a]? }) && (val = json[key]?)))
              @{{ivar.id}} = {{ivar.type}}.new(val, context)
            else
              pp json
              {% if !ivar.type.nilable? && !ivar.has_default_value? %}
                raise CrSerializer::Exceptions::JSONParseError.new("Missing json attribute: '{{ivar}}'")
              {% end %}
            end
          {% end %}
        {% end %}
      {% end %}
    end
  end

  # :nodoc:
  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    process_serialization(context) do |properties|
      JSON.serialize properties, context, builder
    end
  end

  # :nodoc:
  def to_json(context : CrSerializer::SerializationContext = CrSerializer::SerializationContext.new) : String
    serialize JSON, context
  end
end

#######################################################
# Type overloads to (de)serialize to/from this format #
#######################################################

# :nodoc:
class Array
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?)
    json.as_a.map { |val| T.new val, context }
  end

  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.array do
      each &.serialize builder, context
    end
  end
end

# :nodoc:
struct Bool
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : Bool
    json.as_bool
  end

  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.bool self
  end
end

# :nodoc:
struct Enum
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?)
    if val = json.as_i64?
      from_value val
    elsif val = json.as_s?
      parse val
    else
      raise CrSerializer::Exceptions::JSONParseError.new "Could not parse #{{{@type}}} from #{json}"
    end
  end

  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.number value
  end
end

# :nodoc:
class Hash
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?)
    hash = new
    json.as_h.each do |key, value|
      hash[key] = V.new(value, context)
    end
    hash
  end

  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.object do
      each do |key, value|
        builder.field key.to_json_object_key do
          value.serialize(builder, context)
        end
      end
    end
  end
end

# :nodoc:
struct JSON::Any
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?)
    json
  end

  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    raw.serialize builder, context
  end
end

# :nodoc:
struct NamedTuple
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?)
    {% begin %}
      {% for key, type in T %}
        %var{key.id} = (val = json[{{key.id.stringify}}]?) ? {{type}}.new(val, context) : nil
      {% end %}

      {% for key, type in T %}
        if %var{key.id}.nil? && !{{type.nilable?}}
          raise CrSerializer::Exceptions::JSONParseError.new "Missing json attribute: '{{key}}'"
        end
      {% end %}

      {
        {% for key, type in T %}
          {{key}}: (%var{key.id}).as({{type}}),
        {% end %}
      }
    {% end %}
  end

  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.object do
      {% for key in T.keys %}
        builder.field {{key.stringify}} do
          self[{{key.symbolize}}].serialize builder, context
        end
      {% end %}
    end
  end
end

# :nodoc:
struct Nil
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : Nil
    json.as_nil
  end

  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.null
  end
end

# :nodoc:
struct Number
  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.number self
  end
end

# :nodoc:
struct Int8
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : Int8
    json.as_i.to_i8
  end
end

# :nodoc:
struct Int16
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : Int16
    json.as_i.to_i16
  end
end

# :nodoc:
struct Int32
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : Int32
    json.as_i
  end
end

# :nodoc:
struct Int64
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : Int64
    json.as_i64
  end
end

# :nodoc:
struct UInt8
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : UInt8
    json.as_i.to_u8
  end
end

# :nodoc:
struct UInt16
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : UInt16
    json.as_i.to_u16
  end
end

# :nodoc:
struct UInt32
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : UInt32
    json.as_i.to_u32
  end
end

# :nodoc:
struct UInt64
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : UInt64
    json.as_i64.to_u64
  end
end

# :nodoc:
struct Float32
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : Float32
    json.as_f.to_f32
  end
end

# :nodoc:
struct Float64
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : Float64
    json.as_f
  end
end

# :nodoc:
struct Set
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?)
    new json.as_a.map { |val| T.new(val, context) }
  end

  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.array do
      each &.serialize builder, context
    end
  end
end

# :nodoc:
class String
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : String
    json.as_s
  end

  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.string self
  end
end

# :nodoc:
struct Slice
  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.string Base64.encode(self)
  end
end

# :nodoc:
struct Symbol
  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.string to_s
  end
end

# :nodoc:
struct Time
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : Time
    Time::Format::RFC_3339.parse json.as_s
  end

  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.string(Time::Format::RFC_3339.format(self, fraction_digits: 0))
  end
end

# :nodoc:
struct Tuple
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?)
    arr = json.as_a
    {% begin %}
      Tuple.new(
        {% for type, idx in T %}
          {{type}}.new(arr[{{idx}}], context),
        {% end %}
      )
    {% end %}
  end

  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.array do
      {% for _type, idx in T %}
        self[{{idx}}].serialize builder, context
      {% end %}
    end
  end
end

struct Union
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?)
    {% begin %}
      {% non_primitives = [] of Nil %}

      # Try to parse the value as a primitive type first
      # as its faster than trying to parse a non-primitive type
      {% for type, index in T %}
        {% if type == Nil %}
          return nil if json.raw.is_a? Nil
        {% elsif type < Int %}
          if value = json.as_i?
            return {{type}}.new! value
          end
        {% elsif type < Float %}
          if value = json.as_f?
            return {{type}}.new! value
          end
        {% elsif type == Bool || type == String %}
          value = json.raw.as? {{type}}
          return value unless value.nil?
        {% end %}
      {% end %}

      # Parse the type directly if there is only 1 non-primitive type
      {% if non_primitives.size == 1 %}
        return {{non_primitives[0]}}.new json, context
      {% end %}
    {% end %}

    # Lastly, try to parse a non-primitive type if there are more than 1.
    {% for type in T %}
      {% if type == Nil %}
        return nil if json.raw.is_a? Nil
      {% else %}
        begin
          return {{type}}.new json, context
        rescue TypeCastError
          # Ignore
        end
      {% end %}
    {% end %}
    raise CrSerializer::Exceptions::JSONParseError.new "Couldn't parse #{self} from #{json}"
  end
end

# :nodoc:
struct UUID
  def self.new(json : JSON::Any, context : CrSerializer::DeserializationContext?) : UUID
    new json.as_s
  end

  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    builder.string to_s
  end
end

# :nodoc:
struct YAML::Any
  def serialize(builder : JSON::Builder, context : CrSerializer::SerializationContext?) : Nil
    raw.serialize builder, context
  end
end
