require "../../spec_helper"

class GreaterThanOrEqualIntegerTest
  include CrSerializer(JSON | YAML)

  @[Assert::GreaterThanOrEqual(value: 6_i8)]
  property int8 : Int8?

  @[Assert::GreaterThanOrEqual(value: 19_i16)]
  property int16 : Int16?

  @[Assert::GreaterThanOrEqual(value: 0_i32)]
  property int32 : Int32?

  @[Assert::GreaterThanOrEqual(value: -10_i64)]
  property int64 : Int64?
end

class GreaterThanOrEqualFloatTest
  include CrSerializer(JSON | YAML)

  @[Assert::GreaterThanOrEqual(value: 6.123_f32)]
  property float32 : Float32?

  @[Assert::GreaterThanOrEqual(value: 0.0001_f64)]
  property float64 : Float64?
end

class GreaterThanOrEqualStringTest
  include CrSerializer(JSON | YAML)

  @[Assert::GreaterThanOrEqual(value: "X")]
  property str : String?
end

class GreaterThanOrEqualDateTest
  include CrSerializer(JSON | YAML)

  @[Assert::GreaterThanOrEqual(value: Time.new(2017, 6, 6, location: Time::Location::UTC))]
  property startdate : Time?

  @[Assert::GreaterThanOrEqual(value: startdate)]
  property enddate : Time?
end

class GreaterThanOrEqualArrayTest
  include CrSerializer(JSON | YAML)

  @[Assert::GreaterThanOrEqual(value: [1, 2, 3])]
  property arr : Array(Int32)?
end

class GreaterThanOrEqualTestMessage
  include CrSerializer(JSON | YAML)

  @[Assert::GreaterThanOrEqual(value: 12, message: "Expected {{field}} to be greater than or equal to {{value}} but got {{actual}}")]
  property age : Int32
end

class GreaterThanOrEqualTestMissingValue
  include CrSerializer(JSON | YAML)

  @[Assert::GreaterThanOrEqual]
  property age : Int32
end

describe Assert::GreaterThanOrEqual do
  describe "integer" do
    describe "with valid values" do
      it "should be valid" do
        model = GreaterThanOrEqualIntegerTest.from_json(%({"int8": 50,"int16": 19,"int32": 0,"int64": -10}))
        model.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = GreaterThanOrEqualIntegerTest.from_json(%({"int8": null,"int16": null,"int32": null,"int64": null}))
        model.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = GreaterThanOrEqualIntegerTest.from_json(%({"int8": 1,"int16": 6,"int32": -1,"int64": -11}))
        model.valid?.should be_false
        model.errors.size.should eq 4
        model.errors[0].should eq "'int8' should be greater than or equal to 6"
        model.errors[1].should eq "'int16' should be greater than or equal to 19"
        model.errors[2].should eq "'int32' should be greater than or equal to 0"
        model.errors[3].should eq "'int64' should be greater than or equal to -10"
      end
    end
  end

  describe "float" do
    describe "with valid values" do
      it "should be valid" do
        model = GreaterThanOrEqualFloatTest.from_json(%({"float32": 6.123,"float64": 0.1}))
        model.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = GreaterThanOrEqualFloatTest.from_json(%({"float32": null,"float64": null}))
        model.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = GreaterThanOrEqualFloatTest.from_json(%({"float32": 5.99,"float64": 0.000099}))
        model.valid?.should be_false
        model.errors.size.should eq 2
        model.errors[0].should eq "'float32' should be greater than or equal to 6.123"
        model.errors[1].should eq "'float64' should be greater than or equal to 0.0001"
      end
    end
  end

  describe "string" do
    describe "with valid values" do
      it "should be valid" do
        model = GreaterThanOrEqualStringTest.from_json(%({"str": "X"}))
        model.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = GreaterThanOrEqualStringTest.from_json(%({"str": null}))
        model.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = GreaterThanOrEqualStringTest.from_json(%({"str": "G"}))
        model.valid?.should be_false
        model.errors.size.should eq 1
        model.errors[0].should eq "'str' should be greater than or equal to X"
      end
    end
  end

  describe "date" do
    describe "with valid values" do
      it "should be valid" do
        model = GreaterThanOrEqualDateTest.from_json(%({"startdate": "2017-06-06T00:00:00Z"}))
        model.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = GreaterThanOrEqualDateTest.from_json(%({"startdate": null}))
        model.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = GreaterThanOrEqualDateTest.from_json(%({"startdate": "2001-06-06T13:12:32Z"}))
        model.valid?.should be_false
        model.errors.size.should eq 1
        model.errors[0].should eq "'startdate' should be greater than or equal to 2017-06-06 00:00:00 UTC"
      end
    end

    describe "with enddate before startdate" do
      it "should be invalid" do
        model = GreaterThanOrEqualDateTest.from_json(%({"startdate": "2001-06-06T13:12:32Z", "enddate": "2000-06-06T13:12:32Z"}))
        model.valid?.should be_false
        model.errors.size.should eq 2
        model.errors[0].should eq "'startdate' should be greater than or equal to 2017-06-06 00:00:00 UTC"
        model.errors[1].should eq "'enddate' should be greater than or equal to 2001-06-06 13:12:32 UTC"
      end
    end
  end

  describe "array" do
    describe "with valid values" do
      it "should be valid" do
        model = GreaterThanOrEqualArrayTest.from_json(%({"arr": [1,2,3]}))
        model.valid?.should be_true
      end
    end

    describe "with null values" do
      it "should be valid" do
        model = GreaterThanOrEqualArrayTest.from_json(%({"arr": null}))
        model.valid?.should be_true
      end
    end

    describe "with invalid values" do
      it "should be invalid" do
        model = GreaterThanOrEqualArrayTest.from_json(%({"arr": [1,1,2]}))
        model.valid?.should be_false
        model.errors.size.should eq 1
        model.errors[0].should eq "'arr' should be greater than or equal to [1, 2, 3]"
      end
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = GreaterThanOrEqualTestMessage.from_json(%({"age": 5}))
      model.valid?.should be_false
      model.errors.size.should eq 1
      model.errors.first.should eq "Expected age to be greater than or equal to 12 but got 5"
    end
  end
end
