require "../../spec_helper"

class IsFalseTest
  include CrSerializer::Json

  @[Assert::IsFalse]
  property attending : Bool?
end

class IsFalseTestMessage
  include CrSerializer::Json

  @[Assert::IsFalse(message: "Expected {{field}} to be false but got {{actual}}")]
  property attending : Bool
end

describe Assert::IsFalse do
  it "should be valid" do
    model = IsFalseTest.deserialize(%({"attending":false}))
    model.validator.valid?.should be_true
  end

  describe "with nil property" do
    it "should be invalid" do
      model = IsFalseTest.deserialize(%({"attending":null}))
      model.validator.valid?.should be_true
    end
  end

  describe "with false property" do
    it "should be invalid" do
      model = IsFalseTest.deserialize(%({"attending":true}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'attending' should be false"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = IsFalseTestMessage.deserialize(%({"attending":true}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Expected attending to be false but got true"
    end
  end
end
