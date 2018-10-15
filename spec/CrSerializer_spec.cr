require "./spec_helper"

class SerializedNameTest
  include CrSerializer::Json

  @[CrSerializer::Json::Options(serialized_name: "years_young")]
  property age : Int32
end

class ExposeTest
  include CrSerializer::Json

  @[CrSerializer::Json::Options(expose: false)]
  property age : Int32

  property name : String
end

class EmitNullTest
  include CrSerializer::Json

  @[CrSerializer::Json::Options(emit_null: true)]
  property age : Int32?

  property name : String

  property im_null : String? = nil
end

class AccessorTest
  include CrSerializer::Json

  @[CrSerializer::Json::Options(accessor: get_name)]
  property name : String

  def get_name : String
    @name.upcase
  end
end

class ReadOnlyTest
  include CrSerializer::Json

  property age : Int32

  @[CrSerializer::Json::Options(readonly: true)]
  property name : String?
end

class NestedTest
  include CrSerializer::Json

  property name : String

  property age : Age

  property friends : Array(String)
end

class Age
  include CrSerializer::Json

  @[CrSerializer::Assertions(less_than: 10)]
  property yrs : Int32
end

@[CrSerializer::Options(raise_on_invalid: true)]
class RaiseTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(equal: 10)]
  property age : Int32
end

@[CrSerializer::Options(validate: false)]
class ValidateTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(equal: 10)]
  property age : Int32
end

@[CrSerializer::Options(exclusion_policy: :exclude_all)]
class ExcludeAlltest
  include CrSerializer::Json

  property age : Int32 = 22
  property name : String = "Joe"

  @[CrSerializer::Json::Options(expose: true)]
  property value : String = "foo"
end

describe CrSerializer do
  describe "serialize" do
    describe "#serialized_name" do
      it "should serialize correctly" do
        model = SerializedNameTest.new
        model.age = 77
        model.serialize.should eq %({"years_young":77})
      end
    end

    describe "#expose" do
      it "should serialize correctly" do
        model = ExposeTest.new
        model.name = "John"
        model.age = 77
        model.serialize.should eq %({"name":"John"})
      end
    end

    describe "#emit_null" do
      it "should serialize correctly" do
        model = EmitNullTest.new
        model.name = "John"
        model.im_null = "foo"
        model.serialize.should eq %({"age":null,"name":"John","im_null":"foo"})
      end

      it "should not emit_null by default" do
        model = EmitNullTest.new
        model.name = "John"
        model.serialize.should eq %({"age":null,"name":"John"})
      end
    end

    describe "#accessor" do
      it "should serialize correctly" do
        model = AccessorTest.new
        model.name = "John"
        model.serialize.should eq %({"name":"JOHN"})
      end
    end

    describe "#exclusion_policy" do
      it "should not expose properties by default" do
        model = ExcludeAlltest.new
        model.serialize.should eq %({"value":"foo"})
      end
    end
  end

  describe "deserialize" do
    describe "#readonly" do
      it "should deserialize correctly" do
        model = ReadOnlyTest.deserialize %({"name":"Secret","age":22})
        model.age.should eq 22
        model.name.should be_nil
      end
    end

    describe "nested classes" do
      it "should deserialize correctly" do
        model = NestedTest.deserialize %({"name":"John","age":{"yrs": 5},"friends":["Joe","Fred","Bob"]})
        model.name.should eq "John"
        model.age.should be_a Age
        model.age.yrs.should eq 5
        model.friends.should eq %w(Joe Fred Bob)
      end

      it "should validate nested classes" do
        model = NestedTest.deserialize %({"name":"John","age":{"yrs": 15},"friends":["Joe","Fred","Bob"]})
        model.validator.valid?.should be_true
        model.age.validator.valid?.should be_false
        model.age.validator.errors.first.should eq "`yrs` should be less than 10"
      end
    end

    describe "#raise_on_invalid" do
      it "should raise correct exception" do
        expect_raises CrSerializer::ValidationException, "Validation tests failed" { RaiseTest.deserialize %({"age":22}) }
      end

      it "should build correct exception object" do
        begin
          RaiseTest.deserialize %({"age":22})
        rescue ex : CrSerializer::ValidationException
          ex.message.should eq "Validation tests failed"
          ex.to_json.should eq %({"code":400,"message":"Validation tests failed","errors":["`age` should equal 10"]})
        end
      end
    end

    describe "#validate" do
      it "should deserialize correctly" do
        model = ValidateTest.deserialize %({"age":22})
        model.validator.valid?.should be_true
        model.age.should eq 22
      end
    end
  end
end
