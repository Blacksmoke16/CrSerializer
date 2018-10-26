require "./assertion"
require "../../exceptions/missing_field_exception"

module CrSerializer::Assertions
  # Base class for the comparison assertions
  #
  # NOTE: value can be: a hardcoded value like `10`, the name of another property, or the name of a method
  abstract class ComparisonAssertion(T) < Assertion
    def initialize(field : String, message : String?, @actual : T, @value : T)
      super field, message
    end
  end
end
