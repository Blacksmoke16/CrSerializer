require "./interfaces/range_assertion"

module CrSerializer::Assertions
  # Validates a property is within a given range
  #
  # Usable on only Number properties
  #
  # ```
  # @[CrSerializer::Assertions::InRange(range: 0_f64..100_f64)]
  # property age : Int64
  # ```
  #
  # NOTE: Nil values are considered valid
  # NOTE: range must be of type `Range(Float64, Float64)`
  class InRangeAssertion(ActualValueType) < RangeAssertion(ActualValueType)
    def valid? : Bool
      act : ActualValueType = @actual
      min_message : String? = @min_message
      max_message : String? = @max_message
      return true unless act
      return true if @range === act
      return false unless min_message || max_message
      exclusive : Bool = @range.excludes_end?
      is_high : Bool = exclusive ? act > @range.end : act >= @range.end
      if is_high && max_message
        @message = max_message
      elsif !is_high && min_message
        @message = min_message
      end
      false
    end
  end
end
