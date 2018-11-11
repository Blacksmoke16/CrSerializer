require "./interfaces/comparison_assertion"

module CrSerializer::Assertions
  # Validates a property is not equal to a value
  #
  # Usable on all data types
  #
  # ```
  # @[CrSerializer::Assertions::NotNotEqualTo(value: "Fred")]
  # property first_name : String
  # ```
  #
  # NOTE: For not nil assertion see `NotNilAssertion`
  class NotEqualToAssertion(ActualValueType) < ComparisonAssertion(ALLDATATYPES)
    def valid? : Bool
      @actual != @value
    end
  end
end
