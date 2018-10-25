require "../../spec_helper"

class LessThanTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::LessThan(value: 12)]
  property age : Int32?
end

class LessThanTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::LessThan(value: 12, message: "Age should be less than 12")]
  property age : Int32
end

class LessThanTestPropertyPath
  include CrSerializer::Json

  @[CrSerializer::Assertions::LessThan(property_path: current_age)]
  property age : Int32

  property current_age : Int32 = 15
end

class LessThanTestMissingValue
  include CrSerializer::Json

  @[CrSerializer::Assertions::LessThan]
  property age : Int32
end

describe "Assertions::LessThan" do
  it "should be valid" do
    model = LessThanTest.deserialize(%({"age": 10}))
    model.validator.valid?.should be_true
  end

  describe "with bigger property" do
    it "should be invalid" do
      model = LessThanTest.deserialize(%({"age": 123}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'age' has failed the less_than_assertion"
    end
  end

  describe "with nil property" do
    it "should be valid" do
      model = LessThanTest.deserialize(%({"age": null}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = LessThanTestMessage.deserialize(%({"age": 123}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Age should be less than 12"
    end
  end

  describe "with a property path" do
    it "should use the property path's value" do
      model = LessThanTestPropertyPath.deserialize(%({"age": 12}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a missing field" do
    it "should raise an exception" do
      expect_raises CrSerializer::Exceptions::MissingFieldException, "Missing required field(s). value or property_path must be supplied" { LessThanTestMissingValue.deserialize(%({"age": 15})) }
    end
  end
end
