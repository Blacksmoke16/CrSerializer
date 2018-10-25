require "../interfaces/basic_assertion"

module CrSerializer::Assertions
  # Validates a property is not nil
  #
  # Usable on all data types
  #
  # ```
  # @[CrSerializer::Assertions::NotNil]
  # property name : String
  # ```
  class NotNilAssertion(ActualValueType) < BasicAssertion(CrSerializer::Assertions::ALL_DATA_TYPES)
    def valid? : Bool
      @actual.nil? == false
    end
  end
end
