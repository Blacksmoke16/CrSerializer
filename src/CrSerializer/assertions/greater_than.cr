require "./interfaces/comparison_assertion"

module CrSerializer::Assertions
  # Validates a property is greater than a value
  #
  # Usable on only Number properties
  #
  # ```
  # @[CrSerializer::Assertions::GreaterThan(value: 100)]
  # property age : Int64
  # ```
  #
  # NOTE: Nil values are considered valid
  class GreaterThanAssertion(ActualValueType) < ComparisonAssertion(NUMERICDATATYPES?)
    def valid? : Bool
      (value = @value) && (actual = @actual) ? actual > value : true
    end
  end
end
