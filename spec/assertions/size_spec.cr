require "../spec_helper"

class SizeTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(size: 1..5)]
  property first : String

  @[CrSerializer::Assertions(size: 1...4)]
  property last : String

  @[CrSerializer::Assertions(size: 0..3)]
  property skills : Array(String)

  @[CrSerializer::Assertions(size: 0...3)]
  property friends : Array(String)
end

describe "Assertions::Size" do
  it "should be valid" do
    model = SizeTest.deserialize(%({"first": "John","skills":[],"last":"Sno","friends":[]}))
    model.validator.valid?.should be_true
  end

  describe "it should be invalid" do
    describe "with a string" do
      it "that is too long" do
        model = SizeTest.deserialize(%({"first": "123456","skills":[],"last":"Snow","friends":[]}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 2
        model.validator.errors.first.should eq "The size of `first` should be between 1 and 5 inclusive"
        model.validator.errors[1].should eq "The size of `last` should be between 1 and 4 exclusive"
      end

      it "that is too short" do
        model = SizeTest.deserialize(%({"first": "","skills":[],"last":"","friends":[]}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 2
        model.validator.errors.first.should eq "The size of `first` should be between 1 and 5 inclusive"
        model.validator.errors[1].should eq "The size of `last` should be between 1 and 4 exclusive"
      end
    end

    describe "with a array" do
      it "that is too long" do
        model = SizeTest.deserialize(%({"first": "123","skills":["one","two","three","four"],"friends":["one","two","three"],"last":"Sno"}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 2
        model.validator.errors.first.should eq "The size of `skills` should be between 0 and 3 inclusive"
        model.validator.errors[1].should eq "The size of `friends` should be between 0 and 3 exclusive"
      end
    end
  end
end
