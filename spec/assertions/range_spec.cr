require "../spec_helper"

class RangeTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(range: 0..100)]
  property age : Int32

  @[CrSerializer::Assertions(range: 5.00...75.00)]
  property exp : Float64
end

describe "Assertions::Range" do
  it "should be valid" do
    model = RangeTest.deserialize(%({"age": 15, "exp": 55.00}))
    model.validator.valid?.should be_true
  end

  it "should be invalid" do
    model = RangeTest.deserialize(%({"age": -1, "exp": 75.00}))
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 2
    model.validator.errors.first.should eq "`age` should be between 0 and 100 inclusive"
    model.validator.errors[1].should eq "`exp` should be between 5.0 and 75.0 exclusive"
  end
end
