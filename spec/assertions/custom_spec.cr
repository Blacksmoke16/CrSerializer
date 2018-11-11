require "../../spec_helper"

# Test class
class CustomTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::Foo]
  property name : String?
end

# Define an assertion handler
module CrSerializer::Assertions
  class FooAssertion(ActualValueType) < BasicAssertion(CrSerializer::Assertions::ALLDATATYPES)
    def valid?
      @actual == "foo"
    end
  end
end

# Register the assertion and properties
register_assertion CrSerializer::Assertions::Foo, [] of Symbol

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
      model.validator.errors.first.should eq "'name' has failed the foo_assertion"
    end
  end

  describe "with null name" do
    it "should be invalid since assertion doesn't allow for that" do
      model = CustomTest.deserialize(%({"name":null}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "'name' has failed the foo_assertion"
    end
  end
end
