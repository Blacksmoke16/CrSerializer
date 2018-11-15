require "./assertion"

module CrSerializer::Assertions
  # Asserts that a credit card number passes the [Luhn Algorithm](https://en.wikipedia.org/wiki/Luhn_algorithm).
  #
  # Usable on `String` properties
  #
  # ```
  # @[Assert::Luhn]
  # property cc_number : String
  # ```
  class LuhnAssertion(ActualValueType) < Assertion
    @message : String = "'{{field}}' is an invalid credit card number"

    def initialize(field : String, message : String?, @actual : String?)
      super field, message
    end

    def valid? : Bool
      actual = @actual
      return true if actual.nil?
      characters : Array(Char) = actual.chars
      return false unless characters.all?(&.number?)
      last_dig : Int32 = characters.pop.to_i
      checksum : Int32 = (characters.reverse.map_with_index { |n, idx| val = idx.even? ? n.to_i * 2 : n.to_i; val -= 9 if val > 9; val }.sum + last_dig)
      return false if checksum.zero?
      (checksum % 10).zero?
    end
  end
end
