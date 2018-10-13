require "../spec_helper"

class RegexSpec
  include CrSerializer::Json

  @[CrSerializer::Assertions(regex: /g[0-1]d/)]
  property str : String
end

describe "Assertions::Blank" do
  it "should be valid" do
    model = RegexSpec.deserialize(%({"str": "g1d"}))
    model.validator.valid?.should be_true
  end

  it "should be invalid" do
    model = RegexSpec.deserialize(%({"str": "ged"}))
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 1
    model.validator.errors.first.should eq "`str` should match regex `(?-imsx:g[0-1]d)`"
  end
end
