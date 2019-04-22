require "../../spec_helper"

class EqualToTest
  include CrSerializer(JSON | YAML)

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
  include CrSerializer(JSON | YAML)

  @[Assert::EqualTo(value: 12, message: "Expected {{field}} to equal {{value}} but got {{actual}}")]
  property age : Int32?
end

class EqualToTestProperty
  include CrSerializer(JSON | YAML)

  @[Assert::EqualTo(value: current_age)]
  property age : Int32

  property current_age : Int32 = 12
end

class EqualToTestMethod
  include CrSerializer(JSON | YAML)

  @[Assert::EqualTo(value: get_age)]
  property age : Int32

  def get_age : Int32
    12
  end
end

describe Assert::EqualTo do
  it "should be valid" do
    model = EqualToTest.from_json(%({"age": 12,"attending":true,"cash":99.99,"name":"John"}))
    model.valid?.should be_true
  end

  describe "with not equal property" do
    it "should be invalid" do
      model = EqualToTest.from_json(%({"age": 13,"attending":false,"cash":99.90,"name":"Fred"}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 4
      model.validation_errors[0].should eq "'age' should be equal to 12"
      model.validation_errors[1].should eq "'attending' should be equal to true"
      model.validation_errors[2].should eq "'cash' should be equal to 99.99"
      model.validation_errors[3].should eq "'name' should be equal to John"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = EqualToTestMessage.from_json(%({"age": 123}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "Expected age to equal 12 but got 123"
    end
  end

  describe "with a property" do
    it "should use the property's value" do
      model = EqualToTestProperty.from_json(%({"age": 12}))
      model.valid?.should be_true
    end
  end

  describe "with a method as the value" do
    it "should use the method's value" do
      model = EqualToTestMethod.from_json(%({"age": 12}))
      model.valid?.should be_true
    end
  end
end
