require "../../spec_helper"

class GreaterThanTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::GreaterThan(value: 12)]
  property age : Int32?
end

class GreaterThanTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::GreaterThan(value: 12, message: "Age should be greater than 12")]
  property age : Int32
end

class GreaterThanTestPropertyPath
  include CrSerializer::Json

  @[CrSerializer::Assertions::GreaterThan(property_path: current_age)]
  property age : Int32

  property current_age : Int32 = 15
end

class GreaterThanTestMissingValue
  include CrSerializer::Json

  @[CrSerializer::Assertions::GreaterThan]
  property age : Int32
end

describe "Assertions::GreaterThan" do
  it "should be valid" do
    model = GreaterThanTest.deserialize(%({"age": 50}))
    model.validator.valid?.should be_true
  end

  describe "with smaller property" do
    it "should be invalid" do
      model = GreaterThanTest.deserialize(%({"age": 10}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'age' has failed the greater_than_assertion"
    end
  end

  describe "with nil property" do
    it "should be valid" do
      model = GreaterThanTest.deserialize(%({"age": null}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = GreaterThanTestMessage.deserialize(%({"age": 5}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Age should be greater than 12"
    end
  end

  describe "with a property path" do
    it "should use the property path's value" do
      model = GreaterThanTestPropertyPath.deserialize(%({"age": 50}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a missing field" do
    it "should raise an exception" do
      expect_raises CrSerializer::Exceptions::MissingFieldException, "Missing required field(s). value or property_path must be supplied" { GreaterThanTestMissingValue.deserialize(%({"age": 15})) }
    end
  end
end
