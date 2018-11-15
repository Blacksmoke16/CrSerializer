require "./assertion"

module CrSerializer::Assertions
  # Validates that the child object(s) is valid.  Will render the parent object as invalid if any assertions on the child object(s) fail.
  #
  # Usable on `Klass` and `Array(Klass)`
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
      (actual = @actual).is_a?(Array) ? actual.all? { |i| i.validator.valid? } : actual.validator.valid?
    end
  end
end
