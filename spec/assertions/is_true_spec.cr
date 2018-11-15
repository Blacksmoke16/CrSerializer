require "../../spec_helper"

class IsTrueTest
  include CrSerializer::Json

  @[Assert::IsTrue]
  property attending : Bool?
end

class IsTrueTestMessage
  include CrSerializer::Json

  @[Assert::IsTrue(message: "Expected {{field}} to be true but got {{actual}}")]
  property attending : Bool
end

describe Assert::IsTrue do
  it "should be valid" do
    model = IsTrueTest.deserialize(%({"attending":true}))
    model.validator.valid?.should be_true
  end

  describe "with nil property" do
    it "should be invalid" do
      model = IsTrueTest.deserialize(%({"attending":null}))
      model.validator.valid?.should be_true
    end
  end

  describe "with false property" do
    it "should be invalid" do
      model = IsTrueTest.deserialize(%({"attending":false}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'attending' should be true"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = IsTrueTestMessage.deserialize(%({"attending":false}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Expected attending to be true but got false"
    end
  end
end
