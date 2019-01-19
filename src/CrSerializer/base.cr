require "./validator"
require "./assertions/*"
require "json"
require "yaml"
require "semantic_version"

module CrSerializer
  include JSON::Serializable
  include YAML::Serializable
  include CrSerializer::Assertions

  @[CrSerializer::Options(expose: false)]
  @[JSON::Field(ignore: true)]
  @[YAML::Field(ignore: true)]
  # See `Validator`
  getter validator : CrSerializer::Validator = CrSerializer::Validator.new

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
end
