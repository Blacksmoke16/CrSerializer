require "../../spec_helper"

class EqualToTest
  include CrSerializer::Json

  @[Assert::EqualTo(value: 12_i64)]
  property age : Int64

  @[Assert::EqualTo(value: true)]
  property attending : Bool

  @[Assert::EqualTo(value: 99.99_f32)]
  property cash : Float32

  @[Assert::EqualTo(value: "John")]
  property name : String
end

class EqualToTestMessage
  include CrSerializer::Json

  @[Assert::EqualTo(value: 12, message: "Expected {{field}} to equal {{value}} but got {{actual}}")]
  property age : Int32?
end

class EqualToTestProperty
  include CrSerializer::Json

  @[Assert::EqualTo(value: current_age)]
  property age : Int32

  property current_age : Int32 = 12
end

class EqualToTestMethod
  include CrSerializer::Json

  @[Assert::EqualTo(value: get_age)]
  property age : Int32

  def get_age : Int32
    12
  end
end

describe Assert::EqualTo do
  it "should be valid" do
    model = EqualToTest.deserialize(%({"age": 12,"attending":true,"cash":99.99,"name":"John"}))
    model.validator.valid?.should be_true
  end

  describe "with not equal property" do
    it "should be invalid" do
      model = EqualToTest.deserialize(%({"age": 13,"attending":false,"cash":99.90,"name":"Fred"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 4
      model.validator.errors[0].should eq "'age' should be equal to 12"
      model.validator.errors[1].should eq "'attending' should be equal to true"
      model.validator.errors[2].should eq "'cash' should be equal to 99.99"
      model.validator.errors[3].should eq "'name' should be equal to John"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = EqualToTestMessage.deserialize(%({"age": 123}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Expected age to equal 12 but got 123"
    end
  end

  describe "with a property" do
    it "should use the property's value" do
      model = EqualToTestProperty.deserialize(%({"age": 12}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a method as the value" do
    it "should use the method's value" do
      model = EqualToTestMethod.deserialize(%({"age": 12}))
      model.validator.valid?.should be_true
    end
  end
end
