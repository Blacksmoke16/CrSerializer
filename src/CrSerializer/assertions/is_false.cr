require "./assertion"

module CrSerializer::Assertions
  # Validates a property is false
  #
  # Usable on only `Bool` properties
  #
  # ```
  # @[Assert::IsFalse]
  # property is_attending : Bool
  # ```
  class IsFalseAssertion(ActualValueType) < Assertion
    @message : String = "'{{field}}' should be false"

    def initialize(field : String, message : String?, @actual : Bool?)
      super field, message
    end

    def valid? : Bool
      return true if @actual.nil?
      @actual == false
    end
  end
end
