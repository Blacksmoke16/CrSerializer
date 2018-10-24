require "../interfaces/basic_assertion"

module CrSerializer::Assertions
  # Validates a property is not blank
  #
  # Usable on only String properties
  #
  # ```
  # @[CrSerializer::Assertions::NotBlank]
  # property name : String
  # ```
  class NotBlankAssertion(ActualValueType) < BasicAssertion(String)
    def valid? : Bool
      @actual.blank? == false
    end
  end
end
