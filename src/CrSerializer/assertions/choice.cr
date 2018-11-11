require "./interfaces/comparison_assertion"

module CrSerializer::Assertions
  # Validates a property is a valid choice
  #
  # Usable on all data types
  #
  # ```
  # @[CrSerializer::Assertions::Choice(choices: [10_i64, 50_i64, 100_i64])]
  # property level : Int64
  # ```
  #
  # NOTE: choices array must be of same type as property
  class ChoiceAssertion(ActualValueType) < Assertion
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

    def valid? : Bool
      return true if @actual.nil?
      if (actual = @actual).is_a?(Array)
        matches : Int32 = (Array(ALLDATATYPES).new(actual.size) { |i| actual[i] } & @choices).size

        if min = @min_matches
          if matches < min
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
            if msg = @max_message
              @message = msg
            end
            return false
          else
            return true
          end
        end

        if matches != @choices.size
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
