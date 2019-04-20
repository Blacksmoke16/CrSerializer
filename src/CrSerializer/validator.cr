module CrSerializer(T)
  class Validator
    # Array of errors as to why the object is not valid
    getter errors : Array(String) = [] of String

    # Array of assertions defined on `self`
    getter assertions : Array(CrSerializer::Assertions::Assertion)

    # Runs the given array of assertions upon initialization.  Errors are cached to prevent assertions running multiple times
    def initialize(@assertions : Array(CrSerializer::Assertions::Assertion) = [] of CrSerializer::Assertions::Assertion) : Nil
      @errors = @assertions.reject(&.valid?).map(&.error_message)
    end

    # Returns true if there were no failed assertions, otherwise false
    def valid? : Bool
      @errors.empty?
    end

    # Returns the properties that failed their assertions
    def invalid_properties : Array(String)
      @assertions.reject(&.valid?).map(&.field)
    end
  end
end
