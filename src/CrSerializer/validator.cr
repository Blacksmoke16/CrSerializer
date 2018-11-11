module CrSerializer
  class Validator
    # Array of errors as to why the object is not valid
    getter errors : Array(String) = [] of String

    # Runs the given array of assertions upon initalization.  Errors are cached to prevent assertions running multiple times
    #
    # TODO: Remove `DummyAssertion` once [this issue](https://github.com/crystal-lang/crystal/issues/6996) is resolved.
    def initialize(@assertions : Array(CrSerializer::Assertions::Assertion) = [CrSerializer::Assertions::DummyAssertion.new("", "")] of CrSerializer::Assertions::Assertion) : Nil
      @errors = @assertions.reject(&.valid?).map(&.message)
    end

    # Returns true if there were no failed assertions, otherwise false
    def valid? : Bool
      @errors.empty?
    end
  end
end
