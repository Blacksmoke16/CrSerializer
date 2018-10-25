require "../../spec_helper"

class NotBlankTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::NotBlank]
  property name : String
end

class NotBlankTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::NotBlank(message: "Name should not be blank")]
  property name : String
end

describe "Assertions::NotBlank" do
  it "should be valid" do
    model = NotBlankTest.deserialize(%({"name": "John"}))
    model.validator.valid?.should be_true
  end

  describe "with blank property" do
    it "should be invalid" do
      model = NotBlankTest.deserialize(%({"name": ""}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'name' has failed the not_blank_assertion"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = NotBlankTestMessage.deserialize(%({"name":""}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Name should not be blank"
    end
  end
end
