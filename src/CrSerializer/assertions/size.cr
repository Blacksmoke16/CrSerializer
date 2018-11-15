require "./assertion"

module CrSerializer::Assertions
  # Validates a property's size is within a given `Range`
  #
  # Usable only on types that have a `#size` method, such as Array or String
  #
  # Optional annotation fields:
  # * min_message : `String` - Message to display if the value is too small
  # * max_message : `String` - Message to display if the value is too big
  #
  # ```
  # @[Assert::Size(range: 0_f64..100_f64)]
  # property age : Int64
  # ```
  #
  # NOTE: Nil values are considered valid
  # NOTE: range must be of type `Range(Float64, Float64)`
  class SizeAssertion(ActualValueType) < Assertion
    def initialize(
      field : String,
      message : String?,
      @actual : ActualValueType,
      @range : Range(Float64, Float64),
      @min_message : String? = nil,
      @max_message : String? = nil
    )
      super field, message
    end

    def valid? : Bool
      act : ActualValueType = @actual
      min_message : String? = @min_message
      max_message : String? = @max_message
      return true unless act
      return true if @range === act.size
      exclusive : Bool = @range.excludes_end?
      is_high : Bool = exclusive ? act.size > @range.end : act.size >= @range.end
      if is_high
        @message = "'{{field}}' is too long.  It should have #{@range.end} #{act.is_a?(String) ? "characters" : "elements"} or less"
        if max_message
          @message = max_message
        end
      elsif !is_high
        @message = "'{{field}}' is too short.  It should have #{@range.begin} #{act.is_a?(String) ? "characters" : "elements"} or more"
        if min_message
          @message = min_message
        end
      end
      false
    end
  end
end
