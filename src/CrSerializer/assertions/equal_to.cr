require "./interfaces/comparison_assertion"

module CrSerializer::Assertions
  # Validates a property is equal to a value
  #
  # Usable on all data types
  #
  # ```
  # @[CrSerializer::Assertions::EqualTo(value: 7)]
  # property age : Int64
  # ```
  #
  # NOTE: For nil assertion see `IsNilAssertion`
  class EqualToAssertion(ActualValueType) < ComparisonAssertion(ALLDATATYPES)
    def valid? : Bool
      @actual == @value
    end
  end
end
