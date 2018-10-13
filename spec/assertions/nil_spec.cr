require "../spec_helper"

class NilTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(nil: true)]
  property age : Int32?

  @[CrSerializer::Assertions(nil: false)]
  property exp : Float64?
end

describe "Assertions::Nil" do
  it "should be valid" do
    model = NilTest.deserialize(%({"age": null, "exp": 55.00}))
    model.validator.valid?.should be_true
  end

  it "should be invalid" do
    model = NilTest.deserialize(%({"age": 12, "exp": null}))
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 2
    model.validator.errors.first.should eq "`age` should be nil"
    model.validator.errors[1].should eq "`exp` should not be nil"
  end
end
