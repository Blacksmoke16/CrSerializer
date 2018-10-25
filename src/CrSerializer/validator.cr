module CrSerializer
  class Validator
    getter assertions : Array(CrSerializer::Assertions::Assertion) = [] of CrSerializer::Assertions::Assertion

    # Returns true if the all the assertions are valid, otherwise false
    def valid? : Bool
      assertions.all? do |a|
        valid : Bool? = a.valid?
        valid.nil? || valid == true
      end
    end

    # Returns the assertions that are not valid
    def errors : Array(String)
      assertions.reject(&.valid?).map(&.message)
    end
  end
end
