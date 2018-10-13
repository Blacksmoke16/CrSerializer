require "json"

class Array
  def serialize
    self.map(&.serialize)
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

  def serialize
    json = JSON.build do |json|
      json.object do
        {% begin %}
		    	{% obj = {} of Nil => Nil %}
		      {% for ivar in @type.instance_vars %}
		        {% ann = ivar.annotation(CrSerializer::Json::Options) %}
		        {% if ann && ann[:accessor] %}
		          json.field {{ivar.stringify}}, {{ann[:accessor]}}
		        {% elsif !ann || ann[:expose] == true || ann[:expose] == nil %}
		          {% if (!ann || ann[:emit_null] == true) %}
		          	json.field {{ivar.stringify}}, {{ivar.id}}
		          {% end %}
		        {% end %}
		      {% end %}
		    {% end %}
      end
    end
    json
  end
end

class ValidationException < Exception
  def initialize(@validator : ValidationHelper)
    super "Validation tests failed"
  end

  def message : String?
    @message
  end

  def to_json : String
    {
      code:    400,
      message: message,
      errors:  @validator.errors,
    }.to_json
  end
end

class ValidationHelper
  getter errors : Array(String) = [] of String

  def validate_less_than(field : String, actual : Number?, expected : Number, equal_to : Bool = false) : Void
    return if actual.nil?
    valid : Bool = equal_to == true ? actual <= expected : actual < expected
    @errors << "`#{field}` should be less than #{equal_to ? "or equal to " : ""}#{expected}" unless input < expected
  end

  def validate_greater_than(field : String, actual : Number?, expected : Number, equal_to : Bool = false) : Void
    return if actual.nil?
    valid : Bool = equal_to == true ? actual >= expected : actual > expected
    @errors << "`#{field}` should be greater than #{expected}" unless valid
  end

  def validate_blank(field : String, actual : String?, expected : Bool) : Void
    return if actual.nil?
    valid = expected == true ? actual.blank? : !actual.blank?
    @errors << "`#{field}` should#{expected == false ? " not" : ""} be blank" unless valid
  end

  def validate_nil(field : String, actual : String?, expected : Bool) : Void
    valid = expected == true ? actual.nil? : !actual.nil?
    @errors << "`#{field}` should#{expected == false ? " not" : ""} be nil" unless valid
  end

  def validate_range(field : String, actual : Number?, expected : Range) : Void
    return if actual.nil?
    @errors << "`#{field}` should be between #{expected.begin} and #{expected.end} #{expected.exclusive? ? "exclusive" : "inclusive"}" unless expected.includes? actual
  end

  def valid? : Bool
    @errors.size.zero?
  end
end
