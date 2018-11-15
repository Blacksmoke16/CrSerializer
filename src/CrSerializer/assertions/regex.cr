require "./assertion"

module CrSerializer::Assertions
  # Validates a property matches a `Regex` pattern.
  #
  # Usable on only `String` properties
  #
  # Optional annotation fields:
  # * match : `Bool` - Whether the string should have to match the pattern to be valid.  Default `true`.
  #
  # ```
  # @[Assert::RegexMatch(pattern: /\w+:(\/?\/?)[^\s]+/)]
  # property data : String
  # ```
  #
  # NOTE: Nil values are considered valid
  class RegexMatchAssertion(ActualValueType) < Assertion
    @message : String = "'{{field}}' is not valid"

    def initialize(
      field : String,
      message : String?,
      @actual : String?,
      @pattern : Regex,
      @match : Bool = true
    )
      super field, message
    end

    def valid? : Bool
      @match = true if @match.nil?
      act : String? = @actual
      return true if act.nil?
      matched : Int32? = (act =~ @pattern)
      @match ? !matched.nil? : matched.nil?
    end
  end
end
