require "../spec_helper"

class NotEqualTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(not_equal: 0)]
  property age : Int32

  @[CrSerializer::Assertions(not_equal: 75.50)]
  property exp : Float64

  @[CrSerializer::Assertions(not_equal: false)]
  property is_free : Bool

  @[CrSerializer::Assertions(not_equal: -10.0)]
  property value : Float64

  @[CrSerializer::Assertions(not_equal: "person")]
  property type : String
end

describe "Assertions::NotEqual" do
  it "should be valid" do
    model = NotEqualTest.deserialize(%({"age": 1, "exp": 1, "is_free": true, "value": -15,"type":"animal"}))
    model.validator.valid?.should be_true
  end

  it "should be invalid" do
    model = NotEqualTest.deserialize(%({"age": 0, "exp": 75.5, "is_free": false, "value": -10,"type":"person"}))
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 5
    model.validator.errors.first.should eq "`age` should not equal 0"
    model.validator.errors[1].should eq "`exp` should not equal 75.5"
    model.validator.errors[2].should eq "`is_free` should not equal false"
    model.validator.errors[3].should eq "`value` should not equal -10.0"
    model.validator.errors[4].should eq "`type` should not equal person"
  end
end
