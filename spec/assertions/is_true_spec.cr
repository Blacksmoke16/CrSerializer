require "../../spec_helper"

class IsTrueTest
  include CrSerializer

  @[Assert::IsTrue]
  property attending : Bool?
end

class IsTrueTestMessage
  include CrSerializer

  @[Assert::IsTrue(message: "Expected {{field}} to be true but got {{actual}}")]
  property attending : Bool
end

describe Assert::IsTrue do
  it "should be valid" do
    model = IsTrueTest.from_json(%({"attending":true}))
    model.validator.valid?.should be_true
  end

  describe "with nil property" do
    it "should be invalid" do
      model = IsTrueTest.from_json(%({"attending":null}))
      model.validator.valid?.should be_true
    end
  end

  describe "with false property" do
    it "should be invalid" do
      model = IsTrueTest.from_json(%({"attending":false}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'attending' should be true"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = IsTrueTestMessage.from_json(%({"attending":false}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Expected attending to be true but got false"
    end
  end
end
