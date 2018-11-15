require "./assertion"

module CrSerializer::Assertions
  # Validates a property is not equal to a value
  #
  # Usable on all data types
  #
  # ```
  # @[Assert::NotNotEqualTo(value: "Fred")]
  # property first_name : String
  # ```
  #
  # NOTE: value can be: a hardcoded value like `10`, the name of another property, or the name of a method
  # NOTE: For not nil assertion see `NotNilAssertion`
  class NotEqualToAssertion(ActualValueType) < Assertion
    @message : String = "'{{field}}' should be not equal to {{value}}"

    def initialize(field : String, message : String?, @actual : ActualValueType, @value : ActualValueType)
      super field, message
    end

    def valid? : Bool
      @actual != @value
    end
  end
end
