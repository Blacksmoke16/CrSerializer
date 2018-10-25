require "./greater_than"

module CrSerializer::Assertions
  # Validates a property is greater than or equal to a value
  #
  # Usable on only Number properties
  #
  # ```
  # @[CrSerializer::Assertions::GreaterThanOrEqual(value: 100)]
  # property age : Int64
  # ```
  #
  # NOTE: Nil values are considered valid
  class GreaterThanOrEqualAssertion(ActualValueType) < GreaterThanAssertion(ActualValueType)
    def valid? : Bool?
      val = @value
      act = @actual
      return unless val && act
      act >= val
    end
  end
end
