require "./interfaces/basic_assertion"

module CrSerializer::Assertions
  # Validates a property is false
  #
  # Usable on only Bool properties
  #
  # ```
  # @[CrSerializer::Assertions::IsFalse]
  # property is_attending : Bool
  # ```
  class IsFalseAssertion(ActualValueType) < BasicAssertion(Bool?)
    def valid? : Bool
      return true if @actual.nil?
      @actual == false
    end
  end
end
