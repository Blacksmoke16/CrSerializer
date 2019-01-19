require "../../spec_helper"

class GreaterThanIntegerTest
  include CrSerializer

  @[Assert::GreaterThan(value: 6_i8)]
  property int8 : Int8?

  @[Assert::GreaterThan(value: 19_i16)]
  property int16 : Int16?

  @[Assert::GreaterThan(value: 0_i32)]
  property int32 : Int32?

  @[Assert::GreaterThan(value: -10_i64)]
  property int64 : Int64?
end

class GreaterThanFloatTest
  include CrSerializer

  @[Assert::GreaterThan(value: 6.123_f32)]
  property float32 : Float32?

  @[Assert::GreaterThan(value: 0.0001_f64)]
  property float64 : Float64?
end

class GreaterThanStringTest
  include CrSerializer

  @[Assert::GreaterThan(value: "X")]
  property str : String?
end

class GreaterThanDateTest
  include CrSerializer

  @[Assert::GreaterThan(value: Time.new(2010, 1, 1, location: Time::Location::UTC))]
  property startdate : Time?

  @[Assert::GreaterThan(value: startdate)]
  property enddate : Time?
end

class GreaterThanArrayTest
  include CrSerializer

  @[Assert::GreaterThan(value: [1, 2, 3])]
  property arr : Array(Int32)?
end

class GreaterThanTestMessage
  include CrSerializer

  @[Assert::GreaterThan(value: 12, message: "Age should be greater than {{value}} but got {{actual}}")]
  property age : Int32
end

describe Assert::GreaterThan do
  describe "integer" do
    describe "with valid values" do
      it "should be valid" do
        model = GreaterThanIntegerTest.from_json(%({"int8": 50,"int16": 50,"int32": 50,"int64": -9}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = GreaterThanIntegerTest.from_json(%({"int8": null,"int16": null,"int32": null,"int64": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = GreaterThanIntegerTest.from_json(%({"int8": 1,"int16": 6,"int32": 0,"int64": -11}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 4
        model.validator.errors[0].should eq "'int8' should be greater than 6"
        model.validator.errors[1].should eq "'int16' should be greater than 19"
        model.validator.errors[2].should eq "'int32' should be greater than 0"
        model.validator.errors[3].should eq "'int64' should be greater than -10"
      end
    end
  end

  describe "float" do
    describe "with valid values" do
      it "should be valid" do
        model = GreaterThanFloatTest.from_json(%({"float32": 6.2,"float64": 0.1}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = GreaterThanFloatTest.from_json(%({"float32": null,"float64": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = GreaterThanFloatTest.from_json(%({"float32": 5.99,"float64": 0.000099}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 2
        model.validator.errors[0].should eq "'float32' should be greater than 6.123"
        model.validator.errors[1].should eq "'float64' should be greater than 0.0001"
      end
    end
  end

  describe "string" do
    describe "with valid values" do
      it "should be valid" do
        model = GreaterThanStringTest.from_json(%({"str": "Z"}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = GreaterThanStringTest.from_json(%({"str": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = GreaterThanStringTest.from_json(%({"str": "G"}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors[0].should eq "'str' should be greater than X"
      end
    end
  end

  describe "date" do
    describe "with valid values" do
      it "should be valid" do
        model = GreaterThanDateTest.from_json(%({"startdate": "2017-06-06T13:12:32Z"}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = GreaterThanDateTest.from_json(%({"startdate": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = GreaterThanDateTest.from_json(%({"startdate": "2001-06-06T13:12:32Z"}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors[0].should eq "'startdate' should be greater than 2010-01-01 00:00:00 UTC"
      end
    end

    describe "with enddate before startdate" do
      it "should be invalid" do
        model = GreaterThanDateTest.from_json(%({"startdate": "2001-06-06T13:12:32Z", "enddate": "2000-06-06T13:12:32Z"}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 2
        model.validator.errors[0].should eq "'startdate' should be greater than 2010-01-01 00:00:00 UTC"
        model.validator.errors[1].should eq "'enddate' should be greater than 2001-06-06 13:12:32 UTC"
      end
    end
  end

  describe "array" do
    describe "with valid values" do
      it "should be valid" do
        model = GreaterThanArrayTest.from_json(%({"arr": [2,3,4]}))
        model.validator.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = GreaterThanArrayTest.from_json(%({"arr": null}))
        model.validator.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = GreaterThanArrayTest.from_json(%({"arr": [1,1,2]}))
        model.validator.valid?.should be_false
        model.validator.errors.size.should eq 1
        model.validator.errors[0].should eq "'arr' should be greater than [1, 2, 3]"
      end
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = GreaterThanTestMessage.from_json(%({"age": 5}))
      model.validator.valid?.should be_false
      model.validator.errors.size.should eq 1
      model.validator.errors.first.should eq "Age should be greater than 12 but got 5"
    end
  end
end
