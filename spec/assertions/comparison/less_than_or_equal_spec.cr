require "../../spec_helper"

class LessThanOrEqualTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::LessThanOrEqual(value: 10)]
  property age : Int32?
end

class LessThanOrEqualTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::LessThanOrEqual(value: 12, message: "Age should be less than or equal to 12")]
  property age : Int32
end

class LessThanOrEqualTestPropertyPath
  include CrSerializer::Json

  @[CrSerializer::Assertions::LessThanOrEqual(property_path: current_age)]
  property age : Int32

  property current_age : Int32 = 15
end

class LessThanOrEqualTestMissingValue
  include CrSerializer::Json

  @[CrSerializer::Assertions::LessThanOrEqual]
  property age : Int32
end

describe "Assertions::LessThanOrEqual" do
  it "should be valid" do
    model = LessThanOrEqualTest.deserialize(%({"age": 10}))
    model.validator.valid?.should be_true
  end

  describe "with bigger property" do
    it "should be invalid" do
      model = LessThanOrEqualTest.deserialize(%({"age": 123}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'age' has failed the less_than_or_equal_assertion"
    end
  end

  describe "with nil property" do
    it "should be invalid" do
      model = LessThanOrEqualTest.deserialize(%({"age": null}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'age' has failed the less_than_or_equal_assertion"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = LessThanOrEqualTestMessage.deserialize(%({"age": 123}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Age should be less than or equal to 12"
    end
  end

  describe "with a property path" do
    it "should use the property path's value" do
      model = LessThanOrEqualTestPropertyPath.deserialize(%({"age": 15}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a missing field" do
    it "should raise an exception" do
      expect_raises CrSerializer::Exceptions::MissingFieldException, "Missing required field(s). value or property_path must be supplied" { LessThanOrEqualTestMissingValue.deserialize(%({"age": 15})) }
    end
  end
end
