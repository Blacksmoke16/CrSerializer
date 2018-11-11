require "./interfaces/range_assertion"

module CrSerializer::Assertions
  # Validates a property's size is within a given range
  #
  # Usable only on types that have a `#size` method, such as Array or String
  #
  # ```
  # @[CrSerializer::Assertions::Size(range: 0_f64..100_f64)]
  # property age : Int64
  # ```
  #
  # NOTE: Nil values are considered valid
  # NOTE: range must be of type `Range(Float64, Float64)`
  class SizeAssertion(ActualValueType) < RangeAssertion(ActualValueType)
    def valid? : Bool
      act : ActualValueType = @actual
      min_message : String? = @min_message
      max_message : String? = @max_message
      return true unless act
      return true if @range === act.size
      return false unless min_message || max_message
      exclusive : Bool = @range.excludes_end?
      is_high : Bool = exclusive ? act.size > @range.end : act.size >= @range.end
      if is_high && max_message
        @message = max_message
      elsif !is_high && min_message
        @message = min_message
      end
      false
    end
  end
end
