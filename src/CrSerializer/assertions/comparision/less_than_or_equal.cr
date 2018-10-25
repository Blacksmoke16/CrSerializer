require "./less_than"

module CrSerializer::Assertions
  # Validates a property is less than or equal to a value
  #
  # Usable on only Number properties
  #
  # ```
  # @[CrSerializer::Assertions::LessThanOrEqual(value: 100)]
  # property age : Int64
  # ```
  #
  # NOTE: Nil values are considered valid
  class LessThanOrEqualAssertion(ActualValueType) < LessThanAssertion(ActualValueType)
    def valid? : Bool
      val, act = @value, @actual
      return true unless val && act
      act <= val
    end
  end
end
