require "./assertion"

module CrSerializer::Assertions
  # Base class for assertions that use a single `value` annotation field
  #
  # NOTE: value can be: a hardcoded value like `10`, the name of another property, or the name of a method
  abstract class ComparisonAssertion(T) < Assertion
    def initialize(field : String, message : String?, @actual : T, @value : T)
      super field, message
    end
  end
end
