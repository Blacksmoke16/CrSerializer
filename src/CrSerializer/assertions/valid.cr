require "./assertion"

module CrSerializer::Assertions
  # Validates that the child object is valid.  Will render the parent object as invalid if any assertions on the child object fail.
  #
  # Usable on custom Classes
  #
  # ```
  # @[Assert::Valid]
  # property sub_class : MyClass
  # ```
  class ValidAssertion(ActualValueType) < Assertion
    @message : String = "{{field}} should be valid"

    def initialize(
      field : String,
      message : String?,
      @actual : ActualValueType
    )
      super field, message
    end

    def valid? : Bool
      @actual.validator.valid?
    end
  end
end
