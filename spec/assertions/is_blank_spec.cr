require "../../spec_helper"

class IsBlankTest
  include CrSerializer

  @[Assert::IsBlank]
  property name : String?
end

class IsBlankTestMessage
  include CrSerializer

  @[Assert::IsBlank(message: "Expected {{field}} to be blank but got {{actual}}")]
  property name : String
end

describe Assert::IsBlank do
  it "should be valid" do
    model = IsBlankTest.deserialize(%({"name": ""}))
    model.validator.valid?.should be_true
  end

  describe "with blank property" do
    it "should be invalid" do
      model = IsBlankTest.deserialize(%({"name": "Phill"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'name' should be blank"
    end
  end

  describe "with null property" do
    it "should be valid" do
      model = IsBlankTest.deserialize(%({"name": null}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = IsBlankTestMessage.deserialize(%({"name":"Joe"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Expected name to be blank but got Joe"
    end
  end
end
