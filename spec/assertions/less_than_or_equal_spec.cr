require "../../spec_helper"

class LessThanOrEqualIntegerTest
  include CrSerializer

  @[Assert::LessThanOrEqual(value: 6_i8)]
  property int8 : Int8?

  @[Assert::LessThanOrEqual(value: 19_i16)]
  property int16 : Int16?

  @[Assert::LessThanOrEqual(value: 0_i32)]
  property int32 : Int32?

  @[Assert::LessThanOrEqual(value: -10_i64)]
  property int64 : Int64?
end

class LessThanOrEqualFloatTest
  include CrSerializer

  @[Assert::LessThanOrEqual(value: 6.123_f32)]
  property float32 : Float32?

  @[Assert::LessThanOrEqual(value: 0.0001_f64)]
  property float64 : Float64?
end

class LessThanOrEqualStringTest
  include CrSerializer

  @[Assert::LessThanOrEqual(value: "X")]
  property str : String?
end

class LessThanOrEqualDateTest
  include CrSerializer

  @[Assert::LessThanOrEqual(value: Time.new(2017, 6, 6, location: Time::Location::UTC))]
  property startdate : Time?

  @[Assert::LessThanOrEqual(value: startdate)]
  property enddate : Time?
end

class LessThanOrEqualArrayTest
  include CrSerializer

  @[Assert::LessThanOrEqual(value: [1, 2, 3])]
  property arr : Array(Int32)?
end

class LessThanOrEqualTestMessage
  include CrSerializer

  @[Assert::LessThanOrEqual(value: 12, message: "Expected {{field}} to be less than or equal to {{value}} but got {{actual}}")]
  property age : Int32
end

class LessThanOrEqualTestMissingValue
  include CrSerializer

  @[Assert::LessThanOrEqual]
  property age : Int32
end

describe Assert::LessThanOrEqual do
  describe "integer" do
    describe "with valid values" do
      it "should be valid" do
        model = LessThanOrEqualIntegerTest.deserialize(%({"int8": -50,"int16": 19,"int32": 0,"int64": -10}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = LessThanOrEqualIntegerTest.deserialize(%({"int8": null,"int16": null,"int32": null,"int64": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = LessThanOrEqualIntegerTest.deserialize(%({"int8": 90,"int16": 666,"int32": 10,"int64": -9}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 4
        model.validator.errors[0].should eq "'int8' should be less than or equal to 6"
        model.validator.errors[1].should eq "'int16' should be less than or equal to 19"
        model.validator.errors[2].should eq "'int32' should be less than or equal to 0"
        model.validator.errors[3].should eq "'int64' should be less than or equal to -10"
      end
    end
  end

  describe "float" do
    describe "with valid values" do
      it "should be valid" do
        model = LessThanOrEqualFloatTest.deserialize(%({"float32": 6.123,"float64": 0.0}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = LessThanOrEqualFloatTest.deserialize(%({"float32": null,"float64": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = LessThanOrEqualFloatTest.deserialize(%({"float32": 6.99,"float64": 1.000099}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 2
        model.validator.errors[0].should eq "'float32' should be less than or equal to 6.123"
        model.validator.errors[1].should eq "'float64' should be less than or equal to 0.0001"
      end
    end
  end

  describe "string" do
    describe "with valid values" do
      it "should be valid" do
        model = LessThanOrEqualStringTest.deserialize(%({"str": "X"}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = LessThanOrEqualStringTest.deserialize(%({"str": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = LessThanOrEqualStringTest.deserialize(%({"str": "Z"}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors[0].should eq "'str' should be less than or equal to X"
      end
    end
  end

  describe "date" do
    describe "with valid values" do
      it "should be valid" do
        model = LessThanOrEqualDateTest.deserialize(%({"startdate": "2017-06-06T00:00:00Z"}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = LessThanOrEqualDateTest.deserialize(%({"startdate": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = LessThanOrEqualDateTest.deserialize(%({"startdate": "2020-06-06T13:12:32Z"}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors[0].should eq "'startdate' should be less than or equal to 2017-06-06 00:00:00 UTC"
      end
    end

    describe "with enddate before startdate" do
      it "should be invalid" do
        model = LessThanOrEqualDateTest.deserialize(%({"startdate": "2021-06-06T13:12:32Z", "enddate": "2025-06-06T13:12:32Z"}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 2
        model.validator.errors[0].should eq "'startdate' should be less than or equal to 2017-06-06 00:00:00 UTC"
        model.validator.errors[1].should eq "'enddate' should be less than or equal to 2021-06-06 13:12:32 UTC"
      end
    end
  end

  describe "array" do
    describe "with valid values" do
      it "should be valid" do
        model = LessThanOrEqualArrayTest.deserialize(%({"arr": [1,2,3]}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = LessThanOrEqualArrayTest.deserialize(%({"arr": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = LessThanOrEqualArrayTest.deserialize(%({"arr": [4,5,6]}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors[0].should eq "'arr' should be less than or equal to [1, 2, 3]"
      end
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = LessThanOrEqualTestMessage.deserialize(%({"age": 100}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Expected age to be less than or equal to 12 but got 100"
    end
  end
end
