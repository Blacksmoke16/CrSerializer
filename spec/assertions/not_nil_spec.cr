require "../../spec_helper"

class NotNilTest
  include CrSerializer

  @[Assert::NotNil]
  property age : Int32?
end

class NotNilTestMessage
  include CrSerializer

  @[Assert::NotNil(message: "Expected {{field}} to not be null but got {{actual}}")]
  property age : Int32?
end

describe Assert::NotNil do
  it "should be valid" do
    model = NotNilTest.from_json(%({"age": 123}))
    model.validator.valid?.should be_true
  end

  describe "with null property" do
    it "should be invalid" do
      model = NotNilTest.from_json(%({"age": null}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'age' should not be null"
    end
  end

  describe "with missing property" do
    it "should be invalid" do
      model = NotNilTest.from_json(%({}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'age' should not be null"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = NotNilTestMessage.from_json(%({}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Expected age to not be null but got \"\""
    end
  end
end
