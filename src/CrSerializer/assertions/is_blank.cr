require "./interfaces/basic_assertion"

module CrSerializer::Assertions
  # Validates a property is blank
  #
  # Usable on only String properties
  #
  # ```
  # @[CrSerializer::Assertions::IsBlank]
  # property name : String
  # ```
  class IsBlankAssertion(ActualValueType) < BasicAssertion(String?)
    def valid? : Bool
      if actual = @actual
        actual.blank? == true
      else
        true
      end
    end
  end
end
