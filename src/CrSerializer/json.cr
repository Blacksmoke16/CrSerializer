require "json"
require "./validator"
require "./assertions/*"

# :nodoc:
class Array(T)
  def serialize : String
    self.map(&.serialize)
  end

  def self.deserialize(string_or_io) : Array(T)
    Array(T).from_json string_or_io
  end
end

module CrSerializer::Json
  # :nodoc:
  annotation Options; end

  include JSON::Serializable
  include CrSerializer::Assertions

  @[JSON::Field(ignore: true)]
  @[CrSerializer::Json::Options(expose: false)]
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
        {% ann = ivar.annotation(CrSerializer::Json::Options) %}
        {% if ann && ann[:readonly] == true %}
          self.{{ivar.id}} = {{ivar.default_value}}
        {% end %}
      {% end %}
    {% end %}

    # Validations
    {% begin %}
      {% cann = @type.annotation(CrSerializer::Options) %}
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
  def serialize : String
    {% begin %}
      {% properties = {} of Nil => Nil %}
      {% cann = @type.annotation(::CrSerializer::Options) %}
      {% for ivar in @type.instance_vars %}
        {% cr_ann = ivar.annotation(::CrSerializer::Json::Options) %}
        {% unless (cann && cann[:exclusion_policy].resolve == CrSerializer::ExclusionPolicy::EXCLUDE_ALL) && (!cr_ann || cr_ann[:expose] != true) %}
          {% if (!cr_ann || (cr_ann && (cr_ann[:expose] == true || cr_ann[:expose] == nil))) %}
            {%
              properties[ivar.id] = {
                serialized_name: ((cr_ann && cr_ann[:serialized_name]) || ivar).id.stringify,
                emit_null:       (cr_ann && cr_ann[:emit_null] == true) ? true : false,
                value:           (cr_ann && cr_ann[:accessor]) ? cr_ann[:accessor] : ivar.id,
              }
            %}
          {% end %}
        {% end %}
      {% end %}
      json = JSON.build do |json|
        json.object do
          {% for name, value in properties %}
            json.field {{value[:serialized_name]}}, {{value[:value]}} {% unless value[:emit_null] %} unless {{name.id}}.nil? {% end %}
          {% end %}
        end
      end
      json
    {% end %}
  end
end
