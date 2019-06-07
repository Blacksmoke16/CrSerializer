require "./assertion"

module CrSerializer::Assertions
  # Validates a property is not nil
  #
  # Usable on all data types
  #
  # ```
  # @[Assert::NotNil]
  # property name : String
  # ```
  class NotNilAssertion(ActualValueType)
    include Assertion

    @message : String = "'{{field}}' should not be null"

    def initialize(field : String, message : String?, @actual : ActualValueType)
      super field, message
    end

    def valid? : Bool
      @actual.nil? == false
    end
  end
end
