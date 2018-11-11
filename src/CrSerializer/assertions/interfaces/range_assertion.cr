require "./assertion"

module CrSerializer::Assertions
  # Base class for the comparison assertions
  #
  # Optional values:
  # ```
  # min_message : String # => Message to display if the value is too small
  # max_message : String # => Message to display if the value is too big
  # ```
  abstract class RangeAssertion(ActualValueType) < Assertion
    def initialize(field : String, message : String?, @actual : ActualValueType, @range : Range(Float64, Float64), @min_message : String? = nil, @max_message : String? = nil)
      super field, message
    end
  end
end
