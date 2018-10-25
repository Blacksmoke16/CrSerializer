require "../../spec_helper"

class IsFalseTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::IsFalse]
  property attending : Bool
end

class IsFalseTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::IsFalse(message: "Attending should be false")]
  property attending : Bool
end

describe "Assertions::IsFalse" do
  it "should be valid" do
    model = IsFalseTest.deserialize(%({"attending":false}))
    model.validator.valid?.should be_true
  end

  describe "with false property" do
    it "should be invalid" do
      model = IsFalseTest.deserialize(%({"attending":true}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'attending' has failed the is_false_assertion"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = IsFalseTestMessage.deserialize(%({"attending":true}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Attending should be false"
    end
  end
end
