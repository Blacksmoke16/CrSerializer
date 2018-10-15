require "json"
require "./validation_helper"

class Array(T)
  def serialize : String
    self.map(&.serialize)
  end

  def self.deserialize(string_or_io) : Array(T)
    Array(T).from_json string_or_io
  end
end

module CrSerializer::Json
  annotation Options; end

  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  @[CrSerializer::Json::Options(expose: false)]
  getter validator = ValidationHelper.new

  macro included
    def self.deserialize(json_string : String) : self
      from_json(json_string)
    end
  end

  def after_initialize : self
    # Deserialization options
    {% begin %}
      {% for ivar in @type.instance_vars %}
        {% ann = ivar.annotation(CrSerializer::Json::Options) %}
        {% if ann && ann[:readonly] == true %}
          self.{{ivar.id}} = {{ivar.default_value.id}}
        {% end %}
      {% end %}
    {% end %}

    # Validations
    {% begin %}
      {% cann = @type.annotation(CrSerializer::Options) %}
      {% if !cann || cann[:validate] == true || cann[:validate] == nil %}
        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(CrSerializer::Assertions) %}
          {% if ann && ann[:less_than] %}
            @validator.validate_less_than {{ivar.stringify}}, {{ivar.id}}, {{ann[:less_than]}}
          {% end %}
          {% if ann && ann[:less_than_or_equal] %}
            @validator.validate_less_than {{ivar.stringify}}, {{ivar.id}}, {{ann[:less_than_or_equal]}}, true
          {% end %}
          {% if ann && ann[:greater_than] %}
            @validator.validate_greater_than {{ivar.stringify}}, {{ivar.id}}, {{ann[:greater_than]}}
          {% end %}
          {% if ann && ann[:range] %}
            @validator.validate_range {{ivar.stringify}}, {{ivar.id}}, {{ann[:range]}}
          {% end %}
          {% if ann && ann[:size] %}
            @validator.validate_size {{ivar.stringify}}, {{ivar.id}}, {{ann[:size]}}
          {% end %}
          {% if ann && ann[:regex] %}
            @validator.validate_regex {{ivar.stringify}}, {{ivar.id}}, {{ann[:regex]}}
          {% end %}
          {% if ann && ann[:choice] %}
            @validator.validate_choice {{ivar.stringify}}, {{ivar.id}}, {{ann[:choice]}}
          {% end %}
          {% if ann && (ann[:unique] == true || ann[:unique] == false) %}
            @validator.validate_unique {{ivar.stringify}}, {{ivar.id}}, {{ann[:unique]}}
          {% end %}
          {% if ann && ann[:equal] != nil %}
            @validator.validate_equal {{ivar.stringify}}, {{ivar.id}}, {{ann[:equal]}}
          {% end %}
          {% if ann && ann[:not_equal] != nil %}
            @validator.validate_not_equal {{ivar.stringify}}, {{ivar.id}}, {{ann[:not_equal]}}
          {% end %}
          {% if ann && ann[:greater_than_or_equal] %}
            @validator.validate_greater_than {{ivar.stringify}}, {{ivar.id}}, {{ann[:greater_than_or_equal]}}, true
          {% end %}
          {% if ann && (ann[:blank] == true || ann[:blank] == false) %}
            @validator.validate_blank {{ivar.stringify}}, {{ivar}}, {{ann[:blank]}}
          {% end %}
          {% if ann && (ann[:nil] == true || ann[:nil] == false) %}
            @validator.validate_nil {{ivar.stringify}}, {{ivar}}, {{ann[:nil]}}
          {% end %}
        {% end %}
      {% end %}
      {% if cann && cann[:raise_on_invalid] == true %}
        raise ValidationException.new @validator unless @validator.valid?
      {% end %}
    {% end %}
    self
  end

  def serialize : String
    {% begin %}
      {% properties = {} of Nil => Nil %}
      {% cann = @type.annotation(::CrSerializer::Options) %}
      {% for ivar in @type.instance_vars %}
        {% cr_ann = ivar.annotation(::CrSerializer::Json::Options) %}
        {% unless (cann && cann[:exclusion_policy] == :exclude_all) && (!cr_ann || cr_ann[:expose] != true) %}
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
