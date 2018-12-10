require "../../spec_helper"

class NotBlankTest
  include CrSerializer

  @[Assert::NotBlank]
  property name : String?
end

class NotBlankTestMessage
  include CrSerializer

  @[Assert::NotBlank(message: "Expected {{field}} to not be blank but got {{actual}}")]
  property name : String
end

describe Assert::NotBlank do
  it "should be valid" do
    model = NotBlankTest.deserialize(%({"name": "John"}))
    model.validator.valid?.should be_true
  end

  describe "with blank property" do
    it "should be invalid" do
      model = NotBlankTest.deserialize(%({"name": ""}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'name' should not be blank"
    end
  end

  describe "with null property" do
    it "should be valid" do
      model = NotBlankTest.deserialize(%({"name": null}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = NotBlankTestMessage.deserialize(%({"name":""}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Expected name to not be blank but got \"\""
    end
  end
end
