require "../../spec_helper"

class IsBlankTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::IsBlank]
  property name : String
end

class IsBlankTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::IsBlank(message: "Name should be blank")]
  property name : String
end

describe "Assertions::IsBlank" do
  it "should be valid" do
    model = IsBlankTest.deserialize(%({"name": ""}))
    model.validator.valid?.should be_true
  end

  describe "with blank property" do
    it "should be invalid" do
      model = IsBlankTest.deserialize(%({"name": "Phill"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'name' has failed the is_blank_assertion"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = IsBlankTestMessage.deserialize(%({"name":"Joe"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Name should be blank"
    end
  end
end
