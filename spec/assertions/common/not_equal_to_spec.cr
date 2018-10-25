require "../../spec_helper"

class NotEqualToTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::NotEqualTo(value: 12_i64)]
  property age : Int64

  @[CrSerializer::Assertions::NotEqualTo(value: true)]
  property attending : Bool

  @[CrSerializer::Assertions::NotEqualTo(value: 99.99_f32)]
  property cash : Float32

  @[CrSerializer::Assertions::NotEqualTo(value: "John")]
  property name : String
end

class NotEqualToTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::NotEqualTo(value: 12, message: "Age should not equal 12")]
  property age : Int32?
end

class NotEqualToTestPropertyPath
  include CrSerializer::Json

  @[CrSerializer::Assertions::NotEqualTo(property_path: current_age)]
  property age : Int32

  property current_age : Int32 = 13
end

class NotEqualToTestMissingValue
  include CrSerializer::Json

  @[CrSerializer::Assertions::NotEqualTo]
  property age : Int32
end

describe "Assertions::NotEqualTo" do
  it "should be valid" do
    model = NotEqualToTest.deserialize(%({"age": 10,"attending":false,"cash":99.0,"name":"Fred"}))
    model.validator.valid?.should be_true
  end

  describe "with equal property" do
    it "should be invalid" do
      model = NotEqualToTest.deserialize(%({"age": 12,"attending":true,"cash":99.99,"name":"John"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 4
      model.validator.errors.first.should eq "'age' has failed the not_equal_to_assertion"
      model.validator.errors[1].should eq "'attending' has failed the not_equal_to_assertion"
      model.validator.errors[2].should eq "'cash' has failed the not_equal_to_assertion"
      model.validator.errors[3].should eq "'name' has failed the not_equal_to_assertion"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = NotEqualToTestMessage.deserialize(%({"age": 12}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Age should not equal 12"
    end
  end

  describe "with a property path" do
    it "should use the property path's value" do
      model = NotEqualToTestPropertyPath.deserialize(%({"age": 12}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a missing field" do
    it "should raise an exception" do
      expect_raises CrSerializer::Exceptions::MissingFieldException, "Missing required field(s). value or property_path must be supplied" { NotEqualToTestMissingValue.deserialize(%({"age": 12})) }
    end
  end
end
