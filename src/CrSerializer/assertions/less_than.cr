require "./interfaces/comparison_assertion"

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
  # NOTE: Nil values are considered valid
  class LessThanAssertion(ActualValueType) < ComparisonAssertion(NUMERICDATATYPES?)
    def valid? : Bool
      (value = @value) && (actual = @actual) ? actual < value : true
    end
  end
end
