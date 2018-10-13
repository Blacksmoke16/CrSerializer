require "../spec_helper"

class GreaterThanOrEqualTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(greater_than_or_equal: 50)]
  property age : Int32

  @[CrSerializer::Assertions(greater_than_or_equal: 99.5)]
  property exp : Float64
end

describe "Assertions::GreaterThanOrEqual" do
  it "should be valid" do
    model = GreaterThanOrEqualTest.deserialize(%({"age": 50, "exp": 99.5}))
    model.validator.valid?.should be_true
  end

  it "should be invalid" do
    model = GreaterThanOrEqualTest.deserialize(%({"age": 49, "exp": 99.49999999999}))
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 2
    model.validator.errors.first.should eq "`age` should be greater than or equal to 50"
    model.validator.errors[1].should eq "`exp` should be greater than or equal to 99.5"
  end
end
