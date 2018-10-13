require "../spec_helper"

class LessThanTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(less_than: 50)]
  property age : Int32

  @[CrSerializer::Assertions(less_than: 99.5)]
  property exp : Float64
end

describe "Assertions::LessThan" do
  it "should be valid" do
    model = LessThanTest.deserialize(%({"age": 15, "exp": 55.00}))
    model.validator.valid?.should be_true
  end

  it "should be invalid" do
    model = LessThanTest.deserialize(%({"age": 50, "exp": 100}))
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 2
    model.validator.errors.first.should eq "`age` should be less than 50"
    model.validator.errors[1].should eq "`exp` should be less than 99.5"
  end
end
