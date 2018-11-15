require "./assertion"

module CrSerializer::Assertions
  # Validates a property is nil
  #
  # Usable on all data types
  #
  # ```
  # @[Assert::IsNil]
  # property name : String
  # ```
  class IsNilAssertion(ActualValueType) < Assertion
    @message : String = "'{{field}}' should be null"

    def initialize(field : String, message : String?, @actual : ActualValueType)
      super field, message
    end

    def valid? : Bool
      @actual.nil? == true
    end
  end
end
