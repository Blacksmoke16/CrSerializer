module CrSerializer
  class ValidationException < Exception
    def initialize(@validator : ValidationHelper)
      super "Validation tests failed"
    end

    def message : String?
      @message
    end

    def to_json : String
      {
        code:    400,
        message: message,
        errors:  @validator.errors,
      }.to_json
    end
  end
end
