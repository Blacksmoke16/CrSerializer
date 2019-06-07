require "./assertion"

module CrSerializer::Assertions
  # Validates a property is not blank
  #
  # Usable on only `String` properties
  #
  # ```
  # @[Assert::NotBlank]
  # property name : String
  # ```
  class NotBlankAssertion(ActualValueType)
    include Assertion

    @message : String = "'{{field}}' should not be blank"

    def initialize(field : String, message : String?, @actual : String?)
      super field, message
    end

    def valid? : Bool
      if actual = @actual
        actual.blank? == false
      else
        true
      end
    end
  end
end
