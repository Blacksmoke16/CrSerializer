require "./assertion"

module CrSerializer::Assertions
  # Validates a property is a valid choice
  #
  # Usable on all data types
  #
  # Optional annotation fields:
  # * min_matches : `Int32` - Must select _at lest_ `min_matches` to be valid
  # * min_message : `String` - Message to display if too few choices are selected
  # * max_matches : `Int32` - Must select _at most_ `max_matches` to be valid
  # * max_message : `String` - Message to display if too many choices are selected
  # * multiple_message : `String` - Message to display if one or more values in the `actual` value is not in `choices`
  #
  # ```
  # @[Assert::Choice(choices: [10_i64, 50_i64, 100_i64])]
  # property level : Int64
  # ```
  #
  # NOTE: choices array must be of same type as property
  class ChoiceAssertion(ActualValueType)
    include Assertion

    @message : String = "'{{field}}' you selected is not a valid choice"

    def initialize(
      field : String,
      message : String?,
      @actual : ActualValueType,
      @choices : Array(ALLDATATYPES),
      @min_matches : Int32? = nil,
      @max_matches : Int32? = nil,
      @min_message : String? = nil,
      @max_message : String? = nil,
      @multiple_message : String? = nil
    )
      super field, message
    end

    # ameba:disable Metrics/CyclomaticComplexity
    def valid? : Bool
      return true if @actual.nil?
      if (actual = @actual).is_a?(Array)
        matches : Int32 = (Array(ALLDATATYPES).new(actual.size) { |i| actual[i] } & @choices).size

        if min = @min_matches
          if matches < min
            @message = "{{field}}: You must select at least {{min_matches}} choices"
            if msg = @min_message
              @message = msg
            end
            return false
          else
            return true
          end
        end

        if max = @max_matches
          if matches > max
            @message = "{{field}}: You must select at most {{max_matches}} choices"
            if msg = @max_message
              @message = msg
            end
            return false
          else
            return true
          end
        end

        if matches != @choices.size
          @message = "{{field}}: One or more of the given values is invaild"

          if msg = @multiple_message
            @message = msg
          end
          return false
        end

        true
      else
        @choices.includes? @actual
      end
    end
  end
end
