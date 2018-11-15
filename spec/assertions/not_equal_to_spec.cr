require "../../spec_helper"

class NotEqualToTest
  include CrSerializer::Json

  @[Assert::NotEqualTo(value: 12_i64)]
  property age : Int64

  @[Assert::NotEqualTo(value: true)]
  property attending : Bool

  @[Assert::NotEqualTo(value: 99.99_f32)]
  property cash : Float32

  @[Assert::NotEqualTo(value: "John")]
  property name : String
end

class NotEqualToTestMessage
  include CrSerializer::Json

  @[Assert::NotEqualTo(value: 12, message: "Expected {{field}} to not equal {{value}} but got {{actual}}")]
  property age : Int32?
end

class NotEqualToTestProperty
  include CrSerializer::Json

  @[Assert::NotEqualTo(value: current_age)]
  property age : Int32

  property current_age : Int32 = 13
end

class NotEqualToTestMethod
  include CrSerializer::Json

  @[Assert::NotEqualTo(value: get_age)]
  property age : Int32

  def get_age : Int32
    12
  end
end

describe Assert::NotEqualTo do
  it "should be valid" do
    model = NotEqualToTest.deserialize(%({"age": 10,"attending":false,"cash":99.0,"name":"Fred"}))
    model.validator.valid?.should be_true
  end

  describe "with equal property" do
    it "should be invalid" do
      model = NotEqualToTest.deserialize(%({"age": 12,"attending":true,"cash":99.99,"name":"John"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 4
      model.validator.errors[0].should eq "'age' should be not equal to 12"
      model.validator.errors[1].should eq "'attending' should be not equal to true"
      model.validator.errors[2].should eq "'cash' should be not equal to 99.99"
      model.validator.errors[3].should eq "'name' should be not equal to John"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = NotEqualToTestMessage.deserialize(%({"age": 12}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Expected age to not equal 12 but got 12"
    end
  end

  describe "with a property" do
    it "should use the property's value" do
      model = NotEqualToTestProperty.deserialize(%({"age": 12}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a method as the value" do
    it "should use the method's value" do
      model = NotEqualToTestMethod.deserialize(%({"age": 13}))
      model.validator.valid?.should be_true
    end
  end
end
