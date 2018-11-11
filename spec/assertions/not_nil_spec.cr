require "../../spec_helper"

class NotNilTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::NotNil]
  property age : Int32?
end

class NotNilTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::NotNil(message: "Age should not be nil")]
  property age : Int32?
end

describe "Assertions::NotNil" do
  it "should be valid" do
    model = NotNilTest.deserialize(%({"age": 123}))
    model.validator.valid?.should be_true
  end

  describe "with null property" do
    it "should be invalid" do
      model = NotNilTest.deserialize(%({"age": null}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'age' has failed the not_nil_assertion"
    end
  end

  describe "with missing property" do
    it "should be invalid" do
      model = NotNilTest.deserialize(%({}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'age' has failed the not_nil_assertion"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = NotNilTestMessage.deserialize(%({}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Age should not be nil"
    end
  end
end
