require "../../spec_helper"

class IsFalseTest
  include CrSerializer(JSON | YAML)

  @[Assert::IsFalse]
  property attending : Bool?
end

class IsFalseTestMessage
  include CrSerializer(JSON | YAML)

  @[Assert::IsFalse(message: "Expected {{field}} to be false but got {{actual}}")]
  property attending : Bool
end

describe Assert::IsFalse do
  it "should be valid" do
    model = IsFalseTest.from_json(%({"attending":false}))
    model.valid?.should be_true
  end

  describe "with nil property" do
    it "should be invalid" do
      model = IsFalseTest.from_json(%({"attending":null}))
      model.valid?.should be_true
    end
  end

  describe "with false property" do
    it "should be invalid" do
      model = IsFalseTest.from_json(%({"attending":true}))
      model.valid?.should be_false
      model.errors.size.should eq 1
      model.errors.first.should eq "'attending' should be false"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = IsFalseTestMessage.from_json(%({"attending":true}))
      model.valid?.should be_false
      model.errors.size.should eq 1
      model.errors.first.should eq "Expected attending to be false but got true"
    end
  end
end
