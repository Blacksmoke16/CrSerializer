require "./assertion"
require "../../exceptions/missing_field_exception"

module CrSerializer::Assertions
  # Base class for the comparison assertions
  #
  # Optional values:
  # ```
  # property_path: {method/variable name} # => Use a property or method to compare this property's value to, instead of hardcoded value
  # ```
  abstract class ComparisonAssertion(T) < Assertion
    def initialize(field : String, message : String?, @actual : T, value : T = nil, property_path : T = nil)
      raise CrSerializer::Exceptions::MissingFieldException.new(or: {{@type.class.name.stringify.split("Assertion(").first.id}}) if value.nil? && property_path.nil?
      super field, message
      @value = property_path.nil? ? value : property_path
    end
  end
end
