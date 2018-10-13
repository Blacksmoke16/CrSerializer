require "../spec_helper"

class BlankTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(blank: true)]
  property first : String

  @[CrSerializer::Assertions(blank: false)]
  property last : String
end

describe "Assertions::Blank" do
  it "should be valid" do
    model = BlankTest.deserialize(%({"first": "", "last": "Snow"}))
    model.validator.valid?.should be_true
  end

  it "should be invalid" do
    model = BlankTest.deserialize(%({"first": "Jon", "last": ""}))
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 2
    model.validator.errors.first.should eq "`first` should be blank"
    model.validator.errors[1].should eq "`last` should not be blank"
  end
end
