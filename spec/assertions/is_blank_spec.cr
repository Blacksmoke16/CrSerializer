require "../spec_helper"

class IsBlankTest
  include CrSerializer(JSON | YAML)

  @[Assert::IsBlank]
  property name : String?
end

class IsBlankTestMessage
  include CrSerializer(JSON | YAML)

  @[Assert::IsBlank(message: "Expected {{field}} to be blank but got {{actual}}")]
  property name : String
end

describe Assert::IsBlank do
  it "should be valid" do
    model = IsBlankTest.from_json(%({"name": ""}))
    model.valid?.should be_true
  end

  describe "with blank property" do
    it "should be invalid" do
      model = IsBlankTest.from_json(%({"name": "Phill"}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "'name' should be blank"
    end
  end

  describe "with null property" do
    it "should be valid" do
      model = IsBlankTest.from_json(%({"name": null}))
      model.valid?.should be_true
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = IsBlankTestMessage.from_json(%({"name":"Joe"}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "Expected name to be blank but got Joe"
    end
  end
end
