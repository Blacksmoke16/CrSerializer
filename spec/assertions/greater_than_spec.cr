require "../spec_helper"

class GreaterThanTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(greater_than: 50)]
  property age : Int32

  @[CrSerializer::Assertions(greater_than: 99.5)]
  property exp : Float64
end

describe "Assertions::GreaterThan" do
  it "should be valid" do
    model = GreaterThanTest.deserialize(%({"age": 51, "exp": 99.61}))
    model.validator.valid?.should be_true
  end

  it "should be invalid" do
    model = GreaterThanTest.deserialize(%({"age": 50, "exp": 99}))
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 2
    model.validator.errors.first.should eq "`age` should be greater than 50"
    model.validator.errors[1].should eq "`exp` should be greater than 99.5"
  end
end