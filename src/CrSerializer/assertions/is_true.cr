require "./assertion"

module CrSerializer::Assertions
  # Validates a property is true
  #
  # Usable on only `Bool` properties
  #
  # ```
  # @[Assert::IsTrue]
  # property is_attending : Bool
  # ```
  class IsTrueAssertion(ActualValueType) < Assertion
    @message : String = "'{{field}}' should be true"

    def initialize(field : String, message : String?, @actual : Bool?)
      super field, message
    end

    def valid? : Bool
      return true if @actual.nil?
      @actual == true
    end
  end
end
