require "../../spec_helper"

class IsTrueTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::IsTrue]
  property attending : Bool
end

class IsTrueTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::IsTrue(message: "Attending should be true")]
  property attending : Bool
end

describe "Assertions::IsTrue" do
  it "should be valid" do
    model = IsTrueTest.deserialize(%({"attending":true}))
    model.validator.valid?.should be_true
  end

  describe "with false property" do
    it "should be invalid" do
      model = IsTrueTest.deserialize(%({"attending":false}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'attending' has failed the is_true_assertion"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = IsTrueTestMessage.deserialize(%({"attending":false}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Attending should be true"
    end
  end
end
