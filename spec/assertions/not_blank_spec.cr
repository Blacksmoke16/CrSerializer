require "../spec_helper"

class NotBlankTest
  include CrSerializer(JSON | YAML)

  @[Assert::NotBlank]
  property name : String?
end

class NotBlankTestMessage
  include CrSerializer(JSON | YAML)

  @[Assert::NotBlank(message: "Expected {{field}} to not be blank but got {{actual}}")]
  property name : String
end

describe Assert::NotBlank do
  it "should be valid" do
    model = NotBlankTest.from_json(%({"name": "John"}))
    model.valid?.should be_true
  end

  describe "with blank property" do
    it "should be invalid" do
      model = NotBlankTest.from_json(%({"name": ""}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "'name' should not be blank"
    end
  end

  describe "with null property" do
    it "should be valid" do
      model = NotBlankTest.from_json(%({"name": null}))
      model.valid?.should be_true
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = NotBlankTestMessage.from_json(%({"name":""}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "Expected name to not be blank but got \"\""
    end
  end
end
