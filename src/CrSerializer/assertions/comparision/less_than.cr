require "../interfaces/comparison_assertion"

module CrSerializer::Assertions
  # Validates a property is less than a value
  #
  # Usable on only Number properties
  #
  # ```
  # @[CrSerializer::Assertions::LessThan(value: 100)]
  # property age : Int64
  # ```
  #
  # NOTE: Nil values will fail the assertion
  class LessThanAssertion(ActualValueType) < ComparisonAssertion(NUMERIC_DATA_TYPES?)
    def valid? : Bool
      val = @value
      act = @actual
      return false unless val && act
      act < val
    end
  end
end
