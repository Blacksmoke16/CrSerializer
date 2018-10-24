module CrSerializer::Exceptions
  # Exception thrown when an object is not valid and `raise_on_invalid` is true
  class ValidationException < Exception
    def initialize(@validator : Validator)
      super "Validation tests failed"
    end

    # Returns a validation failed 400 JSON error for easy error handling with REST APIs
    #
    # ```
    # {
    #   "code":    400,
    #   "message": "Validation tests failed",
    #   "errors":  [
    #     "'password' should not be blank",
    #     "'age' should be greater than 1",
    #   ],
    # }
    # ```
    def to_json : String
      {
        code:    400,
        message: @message,
        errors:  @validator.errors,
      }.to_json
    end
  end
end
