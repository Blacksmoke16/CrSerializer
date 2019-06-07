require "../spec_helper"

class LuhnTest
  include CrSerializer(JSON | YAML)

  @[Assert::Luhn]
  property cc_number : String?
end

VALID_NUMBERS = [
  "42424242424242424242",
  "378282246310005",
  "371449635398431",
  "378734493671000",
  "5610591081018250",
  "30569309025904",
  "38520000023237",
  "6011111111111117",
  "6011000990139424",
  "3530111333300000",
  "3566002020360505",
  "5555555555554444",
  "5105105105105100",
  "4111111111111111",
  "4012888888881881",
  "4222222222222",
  "5019717010103742",
  "6331101999990016",
]

INVALID_NUMBERS = [
  "1234567812345678",
  "4222222222222222",
  "0000000000000000",
  "000000!000000000",
  "42-22222222222222",
]

describe Assert::Luhn do
  describe "with valid numbers" do
    it "should all be valid" do
      VALID_NUMBERS.each do |cc|
        LuhnTest.from_json(%({"cc_number": "#{cc}"})).valid?.should be_true
      end
    end
  end

  describe "with invalid numbers" do
    it "should all be invalid" do
      INVALID_NUMBERS.each do |cc|
        model = LuhnTest.from_json(%({"cc_number": "#{cc}"}))
        model.valid?.should be_false
        model.validation_errors.size.should eq 1
        model.validation_errors.first.should eq "'cc_number' is an invalid credit card number"
      end
    end
  end
end
