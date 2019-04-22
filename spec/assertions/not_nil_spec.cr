require "../../spec_helper"

class NotNilTest
  include CrSerializer(JSON | YAML)

  @[Assert::NotNil]
  property age : Int32?
end

class NotNilTestMessage
  include CrSerializer(JSON | YAML)

  @[Assert::NotNil(message: "Expected {{field}} to not be null but got {{actual}}")]
  property age : Int32?
end

describe Assert::NotNil do
  it "should be valid" do
    model = NotNilTest.from_json(%({"age": 123}))
    model.valid?.should be_true
  end

  describe "with null property" do
    it "should be invalid" do
      model = NotNilTest.from_json(%({"age": null}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "'age' should not be null"
    end
  end

  describe "with missing property" do
    it "should be invalid" do
      model = NotNilTest.from_json(%({}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "'age' should not be null"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = NotNilTestMessage.from_json(%({}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "Expected age to not be null but got \"\""
    end
  end
end
