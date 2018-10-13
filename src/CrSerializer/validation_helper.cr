module CrSerializer
  class ValidationHelper
    getter errors : Array(String) = [] of String

    # Generic

    def validate_nil(field : String, actual : Object?, expected : Bool) : Void
      valid = expected == true ? actual.nil? : !actual.nil?
      errors << "`#{field}` should#{expected == false ? " not" : ""} be nil" unless valid
    end

    def validate_equal(field : String, actual : Object, expected : Object) : Void
      return if actual.nil?
      errors << "`#{field}` should equal #{expected}" unless actual == expected
    end

    def validate_not_equal(field : String, actual : Object, expected : Object) : Void
      return if actual.nil?
      errors << "`#{field}` should not equal #{expected}" if actual == expected
    end

    def validate_choice(field : String, actual : Object?, expected : Array(String | Number)) : Void
      return if actual.nil?
      errors << "`#{actual}` is not a valid choice" unless expected.includes? actual
    end

    # Numeric

    def validate_less_than(field : String, actual : Number?, expected : Number, equal_to : Bool = false) : Void
      return if actual.nil?
      valid : Bool = equal_to == true ? actual <= expected : actual < expected
      errors << "`#{field}` should be less than #{equal_to ? "or equal to " : ""}#{expected}" unless valid
    end

    def validate_greater_than(field : String, actual : Number?, expected : Number, equal_to : Bool = false) : Void
      return if actual.nil?
      valid : Bool = equal_to == true ? actual >= expected : actual > expected
      errors << "`#{field}` should be greater than #{equal_to ? "or equal to " : ""}#{expected}" unless valid
    end

    def validate_range(field : String, actual : Number?, expected : Range) : Void
      return if actual.nil?
      errors << "`#{field}` should be between #{expected.begin} and #{expected.end} #{expected.exclusive? ? "exclusive" : "inclusive"}" unless expected.includes? actual
    end

    # String

    def validate_blank(field : String, actual : String?, expected : Bool) : Void
      return if actual.nil?
      valid : Bool = expected == true ? actual.blank? : !actual.blank?
      errors << "`#{field}` should#{expected == false ? " not" : ""} be blank" unless valid
    end

    def validate_size(field : String, actual : Object?, expected : Range) : Void
      return if actual.nil?
      errors << "The size of `#{field}` should be between #{expected.begin} and #{expected.end} #{expected.exclusive? ? "exclusive" : "inclusive"}" unless expected.includes? actual.size
    end

    def validate_regex(field : String, actual : String?, expected : Regex) : Void
      return if actual.nil?
      errors << "`#{field}` should match regex `#{expected.to_s}`" if (actual =~ expected).nil?
    end

    # Array

    def validate_unique(field : String, actual : Array(String | Number)?, expected : Bool) : Void
      return if actual.nil?
      valid : Bool = expected == true ? actual.size == actual.uniq.size : !(actual.size == actual.uniq.size)
      errors << "`#{field}` should #{expected ? "" : "not "}be unique" unless valid
    end

    def valid? : Bool
      @errors.size.zero?
    end
  end
end
