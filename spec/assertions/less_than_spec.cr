require "../../spec_helper"

class LessThanTest
  include CrSerializer::Json

  @[Assert::LessThan(value: 12)]
  property age : Int32?
end

class LessThanTestMessage
  include CrSerializer::Json

  @[Assert::LessThan(value: 12, message: "Expcted {{field}} to be less than {{value}} but got {{actual}}")]
  property age : Int32
end

class LessThanTestPropertyPath
  include CrSerializer::Json

  @[Assert::LessThan(value: current_age)]
  property age : Int32

  property current_age : Int32 = 15
end

class LessThanTestMethod
  include CrSerializer::Json

  @[Assert::LessThan(value: get_age)]
  property age : Int32

  def get_age : Int32
    15
  end
end

describe Assert::LessThan do
  it "should be valid" do
    model = LessThanTest.deserialize(%({"age": 10}))
    model.validator.valid?.should be_true
  end

  describe "with bigger property" do
    it "should be invalid" do
      model = LessThanTest.deserialize(%({"age": 123}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'age' should be less than 12"
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
      model.validator.errors.first.should eq "Expcted age to be less than 12 but got 123"
    end
  end

  describe "with a property" do
    it "should use the property's value" do
      model = LessThanTestPropertyPath.deserialize(%({"age": 12}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a method as the value" do
    it "should use the method's value" do
      model = LessThanTestMethod.deserialize(%({"age": 14}))
      model.validator.valid?.should be_true
    end
  end
end
