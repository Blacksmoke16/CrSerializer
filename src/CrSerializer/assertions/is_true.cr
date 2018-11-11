require "./interfaces/basic_assertion"

module CrSerializer::Assertions
  # Validates a property is true
  #
  # Usable on only Bool properties
  #
  # ```
  # @[CrSerializer::Assertions::IsTrue]
  # property is_attending : Bool
  # ```
  class IsTrueAssertion(ActualValueType) < BasicAssertion(Bool?)
    def valid? : Bool
      return true if @actual.nil?
      @actual == true
    end
  end
end
