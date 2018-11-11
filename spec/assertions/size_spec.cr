require "../../spec_helper"

class SizeArrayTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::Size(range: 0_f64..3_f64)]
  property fav_numbers : Array(Int32)?
end

class SizeStringTest
  include CrSerializer::Json

  @[CrSerializer::Assertions::Size(range: 0_f64..10_f64)]
  property password : String?
end

class SizeTestMessage
  include CrSerializer::Json

  @[CrSerializer::Assertions::Size(range: 5_f64..10_f64, min_message: "Password should be at least 5 characters", max_message: "Password cannot be more than 10 characters")]
  property password : String
end

describe "Assertions::Size" do
  context "with an array" do
    describe "with an in range size" do
      it "should be valid" do
        model = SizeArrayTest.deserialize(%({"fav_numbers": [1]}))
        model.validator.valid?.should be_true
      end
    end

    describe "with an out of range size" do
      it "should be invalid" do
        model = SizeArrayTest.deserialize(%({"fav_numbers": [1,2,3,4]}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors.first.should eq "'fav_numbers' has failed the size_assertion"
      end
    end

    describe "with a nil property" do
      it "should be valid" do
        model = SizeArrayTest.deserialize(%({"fav_numbers": null}))
        model.validator.valid?.should be_true
      end
    end
  end

  context "with a string" do
    describe "with an in range size" do
      it "should be valid" do
        model = SizeStringTest.deserialize(%({"password": "aPassword"}))
        model.validator.valid?.should be_true
      end
    end

    describe "with an out of range size" do
      it "should be invalid" do
        model = SizeStringTest.deserialize(%({"password": "tooLongPassword"}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors.first.should eq "'password' has failed the size_assertion"
      end
    end

    describe "with a nil property" do
      it "should be valid" do
        model = SizeStringTest.deserialize(%({"password": null}))
        model.validator.valid?.should be_true
      end
    end
  end

  describe "with a custom message" do
    it "should use correct min_message" do
      model = SizeTestMessage.deserialize(%({"password": "shrt"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Password should be at least 5 characters"
    end

    it "should use correct max_message" do
      model = SizeTestMessage.deserialize(%({"password": "toooooooLong"}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Password cannot be more than 10 characters"
    end
  end
end
