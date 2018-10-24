require "../interfaces/comparison_assertion"

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
  # NOTE: For nil assertion see `NotNilAssertion`
  class NotEqualToAssertion(ActualValueType) < ComparisonAssertion(ALL_DATA_TYPES)
    def valid? : Bool
      @actual != @value
    end
  end
end
