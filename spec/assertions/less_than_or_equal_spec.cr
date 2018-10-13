require "../spec_helper"

class LessThanOrEqualTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(less_than_or_equal: 50)]
  property age : Int32

  @[CrSerializer::Assertions(less_than_or_equal: 99.5)]
  property exp : Float64
end

describe "Assertions::LessThanOrEqual" do
  it "should be valid" do
    model = LessThanOrEqualTest.deserialize(%({"age": 50, "exp": 99}))
    model.validator.valid?.should be_true
  end

  it "should be invalid" do
    model = LessThanOrEqualTest.deserialize(%({"age": 51, "exp": 99.61}))
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 2
    model.validator.errors.first.should eq "`age` should be less than or equal to 50"
    model.validator.errors[1].should eq "`exp` should be less than or equal to 99.5"
  end
end
