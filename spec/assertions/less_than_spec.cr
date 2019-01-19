require "../../spec_helper"

class LessThanIntegerTest
  include CrSerializer

  @[Assert::LessThan(value: 6_i8)]
  property int8 : Int8?

  @[Assert::LessThan(value: 19_i16)]
  property int16 : Int16?

  @[Assert::LessThan(value: 0_i32)]
  property int32 : Int32?

  @[Assert::LessThan(value: -10_i64)]
  property int64 : Int64?
end

class LessThanFloatTest
  include CrSerializer

  @[Assert::LessThan(value: 6.123_f32)]
  property float32 : Float32?

  @[Assert::LessThan(value: 0.0001_f64)]
  property float64 : Float64?
end

class LessThanStringTest
  include CrSerializer

  @[Assert::LessThan(value: "X")]
  property str : String?
end

class LessThanDateTest
  include CrSerializer

  @[Assert::LessThan(value: Time.new(2010, 1, 1, location: Time::Location::UTC))]
  property startdate : Time?

  @[Assert::LessThan(value: startdate)]
  property enddate : Time?
end

class LessThanArrayTest
  include CrSerializer

  @[Assert::LessThan(value: [1, 2, 3])]
  property arr : Array(Int32)?
end

class LessThanTestMessage
  include CrSerializer

  @[Assert::LessThan(value: 12, message: "Age should be less than {{value}} but got {{actual}}")]
  property age : Int32
end

describe Assert::LessThan do
  describe "integer" do
    describe "with valid values" do
      it "should be valid" do
        model = LessThanIntegerTest.from_json(%({"int8": 0,"int16": 18,"int32": -1,"int64": -11}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = LessThanIntegerTest.from_json(%({"int8": null,"int16": null,"int32": null,"int64": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = LessThanIntegerTest.from_json(%({"int8": 90,"int16": 666,"int32": 10,"int64": -9}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 4
        model.validator.errors[0].should eq "'int8' should be less than 6"
        model.validator.errors[1].should eq "'int16' should be less than 19"
        model.validator.errors[2].should eq "'int32' should be less than 0"
        model.validator.errors[3].should eq "'int64' should be less than -10"
      end
    end
  end

  describe "float" do
    describe "with valid values" do
      it "should be valid" do
        model = LessThanFloatTest.from_json(%({"float32": 6.122,"float64": 0.0}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = LessThanFloatTest.from_json(%({"float32": null,"float64": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = LessThanFloatTest.from_json(%({"float32": 7.99,"float64": 2.000099}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 2
        model.validator.errors[0].should eq "'float32' should be less than 6.123"
        model.validator.errors[1].should eq "'float64' should be less than 0.0001"
      end
    end
  end

  describe "string" do
    describe "with valid values" do
      it "should be valid" do
        model = LessThanStringTest.from_json(%({"str": "F"}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = LessThanStringTest.from_json(%({"str": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = LessThanStringTest.from_json(%({"str": "Z"}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors[0].should eq "'str' should be less than X"
      end
    end
  end

  describe "date" do
    describe "with valid values" do
      it "should be valid" do
        model = LessThanDateTest.from_json(%({"startdate": "2000-06-06T13:12:32Z"}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = LessThanDateTest.from_json(%({"startdate": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = LessThanDateTest.from_json(%({"startdate": "2020-06-06T13:12:32Z"}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors[0].should eq "'startdate' should be less than 2010-01-01 00:00:00 UTC"
      end
    end

    describe "with enddate before startdate" do
      it "should be invalid" do
        model = LessThanDateTest.from_json(%({"startdate": "2021-06-06T13:12:32Z", "enddate": "2025-06-06T13:12:32Z"}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 2
        model.validator.errors[0].should eq "'startdate' should be less than 2010-01-01 00:00:00 UTC"
        model.validator.errors[1].should eq "'enddate' should be less than 2021-06-06 13:12:32 UTC"
      end
    end
  end

  describe "array" do
    describe "with valid values" do
      it "should be valid" do
        model = LessThanArrayTest.from_json(%({"arr": [1,1,1]}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = LessThanArrayTest.from_json(%({"arr": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = LessThanArrayTest.from_json(%({"arr": [3,4,5]}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors[0].should eq "'arr' should be less than [1, 2, 3]"
      end
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = LessThanTestMessage.from_json(%({"age": 111}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Age should be less than 12 but got 111"
    end
  end
end
