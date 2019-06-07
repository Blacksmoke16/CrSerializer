require "./assertion"

module CrSerializer::Assertions
  # Validates a property is blank
  #
  # Usable on only `String` properties
  #
  # ```
  # @[Assert::IsBlank]
  # property name : String
  # ```
  class IsBlankAssertion(ActualValueType)
    include Assertion

    @message : String = "'{{field}}' should be blank"

    def initialize(field : String, message : String?, @actual : String?)
      super field, message
    end

    def valid? : Bool
      if actual = @actual
        actual.blank? == true
      else
        true
      end
    end
  end
end
