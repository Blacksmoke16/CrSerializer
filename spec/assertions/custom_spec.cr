require "../../spec_helper"

# Test class
class CustomTest
  include CrSerializer

  @[Assert::Foo]
  property name : String?
end

# Define an assertion handler
class FooAssertion(ActualValueType) < CrSerializer::Assertions::Assertion
  def initialize(field : String, message : String?, @actual : ActualValueType, noop : Nil = nil)
    super field, message
  end

  def valid?
    @actual == "foo"
  end
end

# Register the assertion and properties
register_assertion Assert::Foo, [] of Symbol

describe "Assertions::Custom" do
  describe "with name as `foo`" do
    it "should be valid" do
      model = CustomTest.deserialize(%({"name":"foo"}))
      model.validator.valid?.should be_true
    end
  end

  describe "with name as `bar`" do
    it "should be invalid" do
      model = CustomTest.deserialize(%({"name":"bar"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "The FooAssertion has failed."
    end
  end

  describe "with null name" do
    it "should be invalid since assertion doesn't allow for that" do
      model = CustomTest.deserialize(%({"name":null}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "The FooAssertion has failed."
    end
  end
end
