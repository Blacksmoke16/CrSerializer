require "../../spec_helper"

class GreaterThanTest
  include CrSerializer::Json

  @[Assert::GreaterThan(value: 12)]
  property age : Int32?
end

class GreaterThanTestMessage
  include CrSerializer::Json

  @[Assert::GreaterThan(value: 12, message: "Age should be greater than {{value}} but got {{actual}}")]
  property age : Int32
end

class GreaterThanTestProperty
  include CrSerializer::Json

  @[Assert::GreaterThan(value: current_age)]
  property age : Int32

  property current_age : Int32 = 15
end

class GreaterThanTestMethod
  include CrSerializer::Json

  @[Assert::GreaterThan(value: get_age)]
  property age : Int32

  def get_age : Int32
    25
  end
end

describe Assert::GreaterThan do
  it "should be valid" do
    model = GreaterThanTest.deserialize(%({"age": 50}))
    model.validator.valid?.should be_true
  end

  describe "with smaller property" do
    it "should be invalid" do
      model = GreaterThanTest.deserialize(%({"age": 10}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'age' should be greater than 12"
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
      model.validator.errors.first.should eq "Age should be greater than 12 but got 5"
    end
  end

  describe "with a property" do
    it "should use the property's value" do
      model = GreaterThanTestProperty.deserialize(%({"age": 50}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a method" do
    it "should use the method's value" do
      model = GreaterThanTestMethod.deserialize(%({"age": 26}))
      model.validator.valid?.should be_true
    end
  end
end
