require "./assertion"

module CrSerializer::Assertions
  # Validates a property is equal to a value
  #
  # Usable on all data types
  #
  # ```
  # @[Assert::EqualTo(value: 7)]
  # property age : Int64
  # ```
  #
  # NOTE: For nil assertion see `IsNilAssertion`
  class EqualToAssertion(ActualValueType) < Assertion
    @message : String = "'{{field}}' should be equal to {{value}}"

    def initialize(field : String, message : String?, @actual : ActualValueType, @value : ActualValueType)
      super field, message
    end

    def valid? : Bool
      @actual == @value
    end
  end
end
