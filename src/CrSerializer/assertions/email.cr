require "./assertion"

module CrSerializer::Assertions
  # Which validation pattern to use to validate the email string
  enum EmailValidationMode
    # A simple regular expression. Allows all values with an `@` symbol in, and a `.` in the second host part of the email address.
    LOOSE

    # This matches the pattern used for the [HTML5 email input element](https://www.w3.org/TR/html5/sec-forms.html#email-state-typeemail)
    HTML5

    # TODO Validate against RFC5322
    STRICT
  end

  # Validates a string is a properly formatted email.
  #
  # Usable on only `String` properties
  #
  # Optional annotation fields:
  # * mode : `EmailValidationMode` - Which validation pattern to use See `EmailValidationMode` for more details.  Default `EmailValidationMode::LOOSE`.
  #
  # ```
  # @[Assert::Email]
  # property data : String
  # ```
  #
  # NOTE: Nil values are considered valid
  class EmailAssertion(ActualValueType)
    include Assertion

    LOOSE = /^.+\@\S+\.\S+$/
    HTML5 = /^[a-zA-Z0-9.!\#$\%&\'*+\\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/
    @message : String = "'{{field}}' is not a valid email address"

    def initialize(
      field : String,
      message : String?,
      @actual : String?,
      @mode : EmailValidationMode = EmailValidationMode::LOOSE
    )
      super field, message
    end

    def valid? : Bool
      pattern : Regex = LOOSE
      pattern = HTML5 if @mode.html5?
      act : String? = @actual
      return true if act.nil?
      !(act =~ pattern).nil?
    end
  end
end
