module CrSerializer::Exceptions
  # Exception thrown when an object is not valid and `raise_on_invalid` is true
  class MissingFieldException < Exception
    def initialize(or = nil)
      fields_string : String = CrSerializer::Assertions::ASSERTIONS[or].map { |f| f.to_s }.join (" or ")
      if or
        @message = "Missing required field(s). #{fields_string} must be supplied"
      end
    end
  end
end
