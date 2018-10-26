require "../../spec_helper"

class EqualToTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::EqualTo(value: 12_i64)]
  property age : Int64

  @[CrSerializer::Assertions::EqualTo(value: true)]
  property attending : Bool

  @[CrSerializer::Assertions::EqualTo(value: 99.99_f32)]
  property cash : Float32

  @[CrSerializer::Assertions::EqualTo(value: "John")]
  property name : String
end

class EqualToTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::EqualTo(value: 12, message: "Age should equal 12")]
  property age : Int32?
end

class EqualToTestProperty
  include CrSerializer::Json

  @[CrSerializer::Assertions::EqualTo(value: current_age)]
  property age : Int32

  property current_age : Int32 = 12
end

class EqualToTestMethod
  include CrSerializer::Json

  @[CrSerializer::Assertions::EqualTo(value: get_age)]
  property age : Int32

  def get_age : Int32
    12
  end
end

describe "Assertions::EqualTo" do
  it "should be valid" do
    model = EqualToTest.deserialize(%({"age": 12,"attending":true,"cash":99.99,"name":"John"}))
    model.validator.valid?.should be_true
  end

  describe "with not equal property" do
    it "should be invalid" do
      model = EqualToTest.deserialize(%({"age": 13,"attending":false,"cash":99.90,"name":"Fred"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 4
      model.validator.errors.first.should eq "'age' has failed the equal_to_assertion"
      model.validator.errors[1].should eq "'attending' has failed the equal_to_assertion"
      model.validator.errors[2].should eq "'cash' has failed the equal_to_assertion"
      model.validator.errors[3].should eq "'name' has failed the equal_to_assertion"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = EqualToTestMessage.deserialize(%({"age": 123}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Age should equal 12"
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
