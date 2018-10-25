require "./assertion"
require "../../exceptions/missing_field_exception"

module CrSerializer::Assertions
  # Base class for the comparison assertions
  #
  # Optional values:
  # ```
  # min_message : String # => Message to display if the value is too small
  # max_message : String # => Message to display if the value is too big
  # ```
  abstract class RangeAssertion < Assertion
    def initialize(field : String, message : String?, @actual : NUMERIC_DATA_TYPES?, @range : Range(Float64, Float64), @min_message : String? = nil, @max_message : String? = nil)
      super field, message
    end
  end
end
