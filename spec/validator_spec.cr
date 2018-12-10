require "./spec_helper"

class InvalidPropertiesTest
  include CrSerializer

  @[Assert::EqualTo(value: "foo")]
  property name : String

  @[Assert::EqualTo(value: 22)]
  property number : Int32

  @[Assert::IsTrue]
  property boolean : Bool
end

describe CrSerializer::Validator do
  it "should validate on deserialize" do
    model = Age.deserialize %({"yrs":5})
    model.validator.valid?.should be_true
    model.yrs.should eq 5
  end

  it "should only validate if #validate is called" do
    model = Age.deserialize %({"yrs":5})
    model.validator.valid?.should be_true
    model.yrs.should eq 5
    model.yrs = 100
    model.validator.valid?.should be_true
  end

  it "should validate current state of the object" do
    model = Age.deserialize %({"yrs":5})
    model.validator.valid?.should be_true
    model.yrs.should eq 5

    model.yrs = 100
    model.validate
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 1
    model.validator.errors.first.should eq "'yrs' should be less than 10"
  end

  describe "#assertions" do
    it "should return an array of assertions on the class's instance variables" do
      model = InvalidPropertiesTest.deserialize %({"name":"bar","number": 88,"boolean": true})
      model.validator.assertions.size.should eq 3

      name_assertion = model.validator.assertions[0]
      name_assertion.field.should eq "name"
      name_assertion.actual.should eq "bar"
      name_assertion.message.should eq "'name' should be equal to foo"
      name_assertion.error_message.should eq "'name' should be equal to foo"

      number_assertion = model.validator.assertions[1]
      number_assertion.field.should eq "number"
      number_assertion.actual.should eq 88
      number_assertion.message.should eq "'number' should be equal to 22"
      number_assertion.error_message.should eq "'number' should be equal to 22"

      boolean_assertion = model.validator.assertions[2]
      boolean_assertion.field.should eq "boolean"
      boolean_assertion.actual.should eq true
      boolean_assertion.message.should eq "'{{field}}' should be true"
      boolean_assertion.error_message.should eq "'boolean' should be true"
    end
  end

  describe "#errors" do
    it "should return an array of errors" do
      model = InvalidPropertiesTest.deserialize %({"name":"bar","number": 88,"boolean": true})
      model.validator.errors.size.should eq 2
      model.validator.errors.should eq ["'name' should be equal to foo", "'number' should be equal to 22"]
    end
  end

  describe "#invalid_properties" do
    it "should return an array of properties that failed their assertions" do
      model = InvalidPropertiesTest.deserialize %({"name":"bar","number": 88,"boolean": true})
      model.validator.invalid_properties.should eq %w(name number)
    end
  end
end
