require "./interfaces/assertion"

module CrSerializer::Assertions
  # Validates a property is nil
  #
  # Usable on all data types
  #
  # ```
  # @[CrSerializer::Assertions::IsNil]
  # property name : String
  # ```
  class IsNilAssertion(ActualValueType) < BasicAssertion(CrSerializer::Assertions::ALLDATATYPES)
    def valid? : Bool
      @actual.nil? == true
    end
  end
end
