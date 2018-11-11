require "../../spec_helper"

class ChoiceTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::Choice(choices: [1_i64, 3_i64, 6_i64])]
  property age : Int64?

  @[CrSerializer::Assertions::Choice(choices: [1, 3, 6])]
  property size : Int32

  @[CrSerializer::Assertions::Choice(choices: [false])]
  property attending : Bool

  @[CrSerializer::Assertions::Choice(choices: ["Jim", "Bob", "Fred"])]
  property name : String

  @[CrSerializer::Assertions::Choice(choices: [9.9, 3.14, 2.45])]
  property cash : Float64
end

class ChoiceMultipleTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::Choice(choices: [2, 4, 6], multiple_message: "One ore more value is invalid")]
  property fav_numbers : Array(Int32)
end

class ChoiceMultipleTestMin
  include CrSerializer::Json

  @[CrSerializer::Assertions::Choice(choices: ["a", "b", "c"], min_matches: 2, min_message: "You must have at least 2 choices")]
  property fav_letters : Array(String)
end

class ChoiceMultipleTestMax
  include CrSerializer::Json

  @[CrSerializer::Assertions::Choice(choices: ["a", "b", "c"], max_matches: 2, max_message: "You must have at most 2 choices")]
  property fav_letters : Array(String)
end

class ChoiceTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::Choice(choices: ["Jim", "Bob", "Fred"], message: "Name is not a valid choice")]
  property name : String
end

describe "Assertions::Choice" do
  it "should be valid" do
    model = ChoiceTest.deserialize(%({"age": 1,"size":3,"attending":false,"name":"Bob","cash":3.14}))
    model.validator.valid?.should be_true
  end

  describe "with not valid choices" do
    it "should be invalid" do
      model = ChoiceTest.deserialize(%({"age": 2,"size":2,"attending":true,"name":"Phill","cash":3.16}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 5
      model.validator.errors.first.should eq "'age' has failed the choice_assertion"
      model.validator.errors[1].should eq "'size' has failed the choice_assertion"
      model.validator.errors[2].should eq "'attending' has failed the choice_assertion"
      model.validator.errors[3].should eq "'name' has failed the choice_assertion"
      model.validator.errors[4].should eq "'cash' has failed the choice_assertion"
    end
  end

  describe "with nil value" do
    it "should be valid" do
      model = ChoiceTest.deserialize(%({"age": null,"size":3,"attending":false,"name":"Bob","cash":3.14}))
      model.validator.valid?.should be_true
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = ChoiceTestMessage.deserialize(%({"name":"Kim"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Name is not a valid choice"
    end
  end

  describe "with multiple values" do
    context "min" do
      it "should be valid if number of matches is equal to min_matches" do
        model = ChoiceMultipleTestMin.deserialize(%({"fav_letters": ["a", "b", "d"]}))
        model.validator.valid?.should be_true
      end

      it "should be valid if number of matches is greater than min_matches" do
        model = ChoiceMultipleTestMin.deserialize(%({"fav_letters": ["a", "b", "c"]}))
        model.validator.valid?.should be_true
      end

      it "should be invalid if number of matches is less than min_matches" do
        model = ChoiceMultipleTestMin.deserialize(%({"fav_letters": ["a", "e", "d"]}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors.first.should eq "You must have at least 2 choices"
      end
    end

    context "max" do
      it "should be valid if number of matches is equal to max_matches" do
        model = ChoiceMultipleTestMax.deserialize(%({"fav_letters": ["a", "b", "d"]}))
        model.validator.valid?.should be_true
      end

      it "should be invalid if number of matches is greater than max_matches" do
        model = ChoiceMultipleTestMax.deserialize(%({"fav_letters": ["a", "b", "c"]}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors.first.should eq "You must have at most 2 choices"
      end

      it "should be valid if number of matches is less than max_matches" do
        model = ChoiceMultipleTestMax.deserialize(%({"fav_letters": ["a", "e", "d"]}))
        model.validator.valid?.should be_true
      end
    end

    context "without min/max" do
      it "should be valid if all all values match" do
        model = ChoiceMultipleTest.deserialize(%({"fav_numbers": [2,4,6]}))
        model.validator.valid?.should be_true
      end

      it "should be invalid if one value is not a valid choice" do
        model = ChoiceMultipleTest.deserialize(%({"fav_numbers": [2,4,5]}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors.first.should eq "One ore more value is invalid"
      end

      it "should be invalid if more than one value is not a valid choice" do
        model = ChoiceMultipleTest.deserialize(%({"fav_numbers": [2,3,7]}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors.first.should eq "One ore more value is invalid"
      end
    end
  end
end
