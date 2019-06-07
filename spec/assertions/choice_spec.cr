require "../spec_helper"

class ChoiceTest
  include CrSerializer(JSON | YAML)

  @[Assert::Choice(choices: [1_i64, 3_i64, 6_i64])]
  property age : Int64?

  @[Assert::Choice(choices: [1, 3, 6])]
  property size : Int32

  @[Assert::Choice(choices: [false])]
  property attending : Bool

  @[Assert::Choice(choices: ["Jim", "Bob", "Fred"])]
  property name : String

  @[Assert::Choice(choices: [9.9, 3.14, 2.45])]
  property cash : Float64
end

class ChoiceMultipleTest
  include CrSerializer(JSON | YAML)

  @[Assert::Choice(choices: [2, 4, 6], multiple_message: "One ore more value is invalid")]
  property fav_numbers : Array(Int32)
end

class ChoiceMultipleTestMin
  include CrSerializer(JSON | YAML)

  @[Assert::Choice(choices: ["a", "b", "c"], min_matches: 2, min_message: "You must have at least 2 choices")]
  property fav_letters : Array(String)
end

class ChoiceMultipleTestMinMessage
  include CrSerializer(JSON | YAML)

  @[Assert::Choice(choices: ["a", "b", "c"], min_matches: 2)]
  property fav_letters : Array(String)
end

class ChoiceMultipleTestMax
  include CrSerializer(JSON | YAML)

  @[Assert::Choice(choices: ["a", "b", "c"], max_matches: 2, max_message: "You must have at most 2 choices")]
  property fav_letters : Array(String)
end

class ChoiceMultipleTestMaxMessage
  include CrSerializer(JSON | YAML)

  @[Assert::Choice(choices: ["a", "b", "c"], max_matches: 2)]
  property fav_letters : Array(String)
end

class ChoiceTestMessage
  include CrSerializer(JSON | YAML)

  @[Assert::Choice(choices: ["Jim", "Bob", "Fred"], message: "Name is not a valid choice")]
  property name : String
end

describe Assert::Choice do
  it "should be valid" do
    model = ChoiceTest.from_json(%({"age": 1,"size":3,"attending":false,"name":"Bob","cash":3.14}))
    model.valid?.should be_true
  end

  describe "with not valid choices" do
    it "should be invalid" do
      model = ChoiceTest.from_json(%({"age": 2,"size":2,"attending":true,"name":"Phill","cash":3.16}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 5
      model.validation_errors.first.should eq "'age' you selected is not a valid choice"
      model.validation_errors[1].should eq "'size' you selected is not a valid choice"
      model.validation_errors[2].should eq "'attending' you selected is not a valid choice"
      model.validation_errors[3].should eq "'name' you selected is not a valid choice"
      model.validation_errors[4].should eq "'cash' you selected is not a valid choice"
    end
  end

  describe "with nil value" do
    it "should be valid" do
      model = ChoiceTest.from_json(%({"age": null,"size":3,"attending":false,"name":"Bob","cash":3.14}))
      model.valid?.should be_true
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = ChoiceTestMessage.from_json(%({"name":"Kim"}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "Name is not a valid choice"
    end
  end

  describe "with multiple values" do
    describe "min" do
      it "should be valid if number of matches is equal to min_matches" do
        model = ChoiceMultipleTestMin.from_json(%({"fav_letters": ["a", "b", "d"]}))
        model.valid?.should be_true
      end

      it "should be valid if number of matches is greater than min_matches" do
        model = ChoiceMultipleTestMin.from_json(%({"fav_letters": ["a", "b", "c"]}))
        model.valid?.should be_true
      end

      it "should be invalid if number of matches is less than min_matches" do
        model = ChoiceMultipleTestMin.from_json(%({"fav_letters": ["a", "e", "d"]}))
        model.valid?.should be_false
        model.validation_errors.size.should eq 1
        model.validation_errors.first.should eq "You must have at least 2 choices"
      end

      describe "with the default message" do
        model = ChoiceMultipleTestMinMessage.from_json(%({"fav_letters": ["a", "e", "d"]}))
        model.valid?.should be_false
        model.validation_errors.size.should eq 1
        model.validation_errors.first.should eq "fav_letters: You must select at least 2 choices"
      end
    end

    describe "max" do
      it "should be valid if number of matches is equal to max_matches" do
        model = ChoiceMultipleTestMax.from_json(%({"fav_letters": ["a", "b", "d"]}))
        model.valid?.should be_true
      end

      it "should be invalid if number of matches is greater than max_matches" do
        model = ChoiceMultipleTestMax.from_json(%({"fav_letters": ["a", "b", "c"]}))
        model.valid?.should be_false
        model.validation_errors.size.should eq 1
        model.validation_errors.first.should eq "You must have at most 2 choices"
      end

      it "should be valid if number of matches is less than max_matches" do
        model = ChoiceMultipleTestMax.from_json(%({"fav_letters": ["a", "e", "d"]}))
        model.valid?.should be_true
      end

      describe "with the default message" do
        model = ChoiceMultipleTestMaxMessage.from_json(%({"fav_letters": ["a", "b", "c"]}))
        model.valid?.should be_false
        model.validation_errors.size.should eq 1
        model.validation_errors.first.should eq "fav_letters: You must select at most 2 choices"
      end
    end

    describe "without min/max" do
      it "should be valid if all all values match" do
        model = ChoiceMultipleTest.from_json(%({"fav_numbers": [2,4,6]}))
        model.valid?.should be_true
      end

      it "should be invalid if one value is not a valid choice" do
        model = ChoiceMultipleTest.from_json(%({"fav_numbers": [2,4,5]}))
        model.valid?.should be_false
        model.validation_errors.size.should eq 1
        model.validation_errors.first.should eq "One ore more value is invalid"
      end

      it "should be invalid if more than one value is not a valid choice" do
        model = ChoiceMultipleTest.from_json(%({"fav_numbers": [2,3,7]}))
        model.valid?.should be_false
        model.validation_errors.size.should eq 1
        model.validation_errors.first.should eq "One ore more value is invalid"
      end
    end
  end
end
