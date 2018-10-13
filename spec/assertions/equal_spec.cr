require "../spec_helper"

class EqualTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(equal: 0)]
  property age : Int32

  @[CrSerializer::Assertions(equal: 75.50)]
  property exp : Float64

  @[CrSerializer::Assertions(equal: false)]
  property is_free : Bool

  @[CrSerializer::Assertions(equal: 15.0)]
  property value : Float64

  @[CrSerializer::Assertions(equal: "person")]
  property type : String
end

describe "Assertions::Equal" do
  it "should be valid" do
    model = EqualTest.deserialize(%({"age": 0, "exp": 75.5, "is_free": false, "value": 15, "type":"person"}))
    model.validator.valid?.should be_true
  end

  it "should be invalid" do
    model = EqualTest.deserialize(%({"age": 1, "exp": 74.00, "is_free": true, "value": 15, "type":"animal"}))
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 4
    model.validator.errors.first.should eq "`age` should equal 0"
    model.validator.errors[1].should eq "`exp` should equal 75.5"
    model.validator.errors[2].should eq "`is_free` should equal false"
    model.validator.errors[3].should eq "`type` should equal person"
  end
end
