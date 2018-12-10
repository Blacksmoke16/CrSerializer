require "./assertion"

module CrSerializer::Assertions
  # Validates a property is less than or equal to a value
  #
  # Usable on any type that includes `Comparable`
  #
  # ```
  # @[Assert::LessThanOrEqual(value: 100)]
  # property age : Int64
  # ```
  #
  # NOTE: value can be: a hardcoded value like `10`, the name of another property, or the name of a method
  # NOTE: Nil values are considered valid
  class LessThanOrEqualAssertion(ActualValueType) < Assertion
    @message : String = "'{{field}}' should be less than or equal to {{value}}"

    def initialize(field : String, message : String?, @actual : ActualValueType, @value : ActualValueType)
      super field, message
    end

    def valid? : Bool
      (value = @value) && (actual = @actual) ? actual <= value : true
    end
  end
end
