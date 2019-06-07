require "../spec_helper"

class IsNilTest
  include CrSerializer(JSON | YAML)

  @[Assert::IsNil]
  property age : Int64?

  @[Assert::IsNil]
  property attending : Bool?

  @[Assert::IsNil]
  property cash : Float32?

  @[Assert::IsNil]
  property name : String?
end

class IsNilTestMessage
  include CrSerializer(JSON | YAML)

  @[Assert::IsNil(message: "Expected {{field}} to be nil but got {{actual}}")]
  property age : Int32?
end

describe Assert::IsNil do
  describe "with null property" do
    it "should be valid" do
      model = IsNilTest.from_json(%({"age": null,"attending":null,"cash":null,"name":null}))
      model.valid?.should be_true
    end
  end

  describe "with missing property" do
    it "should be valid" do
      model = IsNilTest.from_json(%({}))
      model.valid?.should be_true
    end
  end

  describe "with non-nil property" do
    it "should be invalid" do
      model = IsNilTest.from_json(%({"age": 12,"attending":true,"cash":99.99,"name":"John"}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 4
      model.validation_errors.first.should eq "'age' should be null"
      model.validation_errors[1].should eq "'attending' should be null"
      model.validation_errors[2].should eq "'cash' should be null"
      model.validation_errors[3].should eq "'name' should be null"
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = IsNilTestMessage.from_json(%({"age": 123}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "Expected age to be nil but got 123"
    end
  end
end
