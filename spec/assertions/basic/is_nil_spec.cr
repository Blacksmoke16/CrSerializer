require "../../spec_helper"

class IsNilTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::IsNil]
  property age : Int64?

  @[CrSerializer::Assertions::IsNil]
  property attending : Bool?

  @[CrSerializer::Assertions::IsNil]
  property cash : Float32?

  @[CrSerializer::Assertions::IsNil]
  property name : String?
end

class IsNilTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::IsNil(message: "Age should be nil")]
  property age : Int32?
end

describe "Assertions::IsNil" do
  describe "with null property" do
    it "should be valid" do
      model = IsNilTest.deserialize(%({"age": null,"attending":null,"cash":null,"name":null}))
      model.validator.valid?.should be_true
    end
  end

  describe "with missing property" do
    it "should be valid" do
      model = IsNilTest.deserialize(%({}))
      model.validator.valid?.should be_true
    end
  end

  describe "with non-nil property" do
    it "should be invalid" do
      model = IsNilTest.deserialize(%({"age": 12,"attending":true,"cash":99.99,"name":"John"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 4
      model.validator.errors.first.should eq "'age' has failed the is_nil_assertion"
      model.validator.errors[1].should eq "'attending' has failed the is_nil_assertion"
      model.validator.errors[2].should eq "'cash' has failed the is_nil_assertion"
      model.validator.errors[3].should eq "'name' has failed the is_nil_assertion"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = IsNilTestMessage.deserialize(%({"age": 123}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Age should be nil"
    end
  end
end
