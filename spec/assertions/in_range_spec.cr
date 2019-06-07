require "../spec_helper"

class InRangeTest
  include CrSerializer(JSON | YAML)

  @[Assert::InRange(range: 0_f64..100_f64)]
  property age : Int64?
end

class InRangeTestMessage
  include CrSerializer(JSON | YAML)

  @[Assert::InRange(range: 0_f64..100_f64, min_message: "Age cannot be negative", max_message: "You cannot live more than 100 years")]
  property age : Int32?
end

describe Assert::InRange do
  it "should be valid" do
    model = InRangeTest.from_json(%({"age": 12}))
    model.valid?.should be_true
  end

  describe "with out of range property" do
    describe "that is too big" do
      it "should be invalid" do
        model = InRangeTest.from_json(%({"age": 150}))
        model.valid?.should be_false
        model.validation_errors.size.should eq 1
        model.validation_errors.first.should eq "'age' should be 100.0 or less"
      end
    end

    describe "that is too small" do
      it "should be invalid" do
        model = InRangeTest.from_json(%({"age": -10}))
        model.valid?.should be_false
        model.validation_errors.size.should eq 1
        model.validation_errors.first.should eq "'age' should be 0.0 or more"
      end
    end
  end

  describe "with a nil property" do
    it "should be valid" do
      model = InRangeTest.from_json(%({"age": null}))
      model.valid?.should be_true
    end
  end

  describe "with a custom message" do
    it "should use correct min_message" do
      model = InRangeTestMessage.from_json(%({"age": -50}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "Age cannot be negative"
    end

    it "should use correct max_message" do
      model = InRangeTestMessage.from_json(%({"age": 150}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "You cannot live more than 100 years"
    end
  end
end
