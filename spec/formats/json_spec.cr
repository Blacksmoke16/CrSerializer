require "../spec_helper"

describe JSON do
  describe ".from_json" do
    describe "that is valid" do
      it "deserializes the given JSON string into the type" do
        obj = TestObject.from_json %({"some_name":"Bob"})
        obj.name.should eq "Bob"
        obj.age.should be_nil
        obj.initialized.should be_true
      end
    end

    describe "that is missing a non-nilable property that doesn't have a default" do
      it "should raise the proper exception" do
        expect_raises CrSerializer::Exceptions::JSONParseError, "Missing json attribute: 'name'" do
          TestObject.from_json %({"age":123})
        end
      end
    end
  end

  describe ".deserialize" do
    describe "invalid value" do
      it "should raise the proper exception" do
        expect_raises CrSerializer::Exceptions::JSONParseError, "Expected Bool but was Int64" do
          Bool.deserialize JSON, "17"
        end
      end
    end

    describe Array do
      describe "of a single type" do
        assert_deserialize_format JSON, Array(Int32), "[1,2,3]", [1, 2, 3]
      end

      describe "of a unioned type" do
        assert_deserialize_format JSON, Array(Int32 | String), %(["one", 17, "99"]), ["one", 17, "99"]
      end

      describe "of hashes" do
        hash = [{"name" => "Jim", "age" => 19}, {"name" => "Jim", "age" => 18, "value": false}]
        assert_deserialize_format JSON, Array(Hash(String, String | Int32 | Bool)), %([{"name":"Jim","age":19},{"name":"Jim","age":18,"value":false}]), hash
      end
    end

    describe Bool do
      assert_deserialize_format JSON, Bool, "true", true
    end

    describe Enum do
      describe String do
        assert_deserialize_format JSON, MyEnum, %("two"), MyEnum::Two
      end

      describe Int do
        assert_deserialize_format JSON, MyEnum, "0", MyEnum::One
      end
    end

    describe Hash do
      describe "simple hash" do
        hash = {"name" => "Jim", "age" => 19}
        assert_deserialize_format JSON, Hash(String, String | Int32), %({"name":"Jim","age":19}), hash
      end

      describe "nested hash" do
        hash = {"name" => "Jim", "age" => 19, "location": {"address" => "123 fake street", "zip": 90210}}
        assert_deserialize_format JSON, Hash(String, String | Int32 | Hash(String, String | Int32)), %({"name":"Jim","age":19,"location":{"address":"123 fake street","zip":90210}}), hash
      end
    end

    describe JSON::Any do
      assert_deserialize_format JSON, JSON::Any, "17", JSON.parse("17")
    end

    describe NamedTuple do
      describe "valid" do
        nt = {numbers: [1, 2, 3], "data": {"name" => "Jim", "age" => 19}}
        assert_deserialize_format JSON, NamedTuple(numbers: Array(Int32), data: Hash(String, String | Int32)), %({"numbers":[1,2,3],"data":{"name":"Jim","age":19}}), nt
      end

      describe "missing key" do
        it "should raise the proper error" do
          expect_raises CrSerializer::Exceptions::JSONParseError, "Missing json attribute: 'active'" do
            NamedTuple(numbers: Array(Int32), data: Hash(String, String | Int32), active: Bool).deserialize JSON, %({"numbers":[1,2,3],"data":{"name":"Jim","age":19}})
          end
        end
      end
    end

    describe Nil do
      assert_deserialize_format JSON, Nil, "null", nil
    end

    describe Number do
      describe Int do
        describe Int8 do
          assert_deserialize_format JSON, Int8, "17", 17_i8
        end

        describe Int16 do
          assert_deserialize_format JSON, Int16, "17", 17_i16
        end

        describe Int32 do
          assert_deserialize_format JSON, Int32, "17", 17
        end

        describe Int64 do
          assert_deserialize_format JSON, Int64, "17", 17_i64
        end

        describe UInt8 do
          assert_deserialize_format JSON, UInt8, "17", 17_u8
        end

        describe UInt16 do
          assert_deserialize_format JSON, UInt16, "17", 17_u16
        end

        describe UInt32 do
          assert_deserialize_format JSON, UInt32, "17", 17_u32
        end

        describe UInt64 do
          assert_deserialize_format JSON, UInt64, "17", 17_u64
        end
      end

      describe Float do
        describe Float32 do
          assert_deserialize_format JSON, Float32, "17.59", 17.59_f32
        end

        describe Float64 do
          assert_deserialize_format JSON, Float64, "17.59", 17.59
        end
      end
    end

    describe Set do
      describe "of a single type" do
        assert_deserialize_format JSON, Set(Int32), "[1,2]", Set{1, 2}
      end

      describe "of mixed types" do
        assert_deserialize_format JSON, Set(Int32 | String), %(["one", 17, "99"]), Set{"one", 17, "99"}
      end
    end

    describe String do
      assert_deserialize_format JSON, String, %("foo"), "foo"
    end

    pending Slice do
    end

    pending Symbol do
    end

    describe Time do
      assert_deserialize_format JSON, Time, %("2016-02-15T10:20:30Z"), Time.utc(2016, 2, 15, 10, 20, 30)
    end

    describe Tuple do
      tup = {99, "foo", false}
      assert_deserialize_format JSON, Tuple(Int32, String, Bool), %([99, "foo", false]), tup
    end

    describe UUID do
      assert_deserialize_format JSON, UUID, %("f89dc089-2c6c-411a-af20-ea98f90376ef"), UUID.new("f89dc089-2c6c-411a-af20-ea98f90376ef")
    end

    describe Union do
      describe "when a value could not be parsed from the union" do
        it "should raise the proper exception" do
          expect_raises CrSerializer::Exceptions::JSONParseError, "Couldn't parse (Bool | String) from 17" do
            (Bool | String).deserialize JSON, "17"
          end
        end
      end

      describe "when it's possible to parse a value from the union" do
        assert_deserialize_format JSON, (String | Bool), "true", true
      end
    end
  end

  describe "#to_json" do
    it "deserializes the given JSON string into the type" do
      TestObject.new("Jim", 123).to_json.should eq %({"the_name":"Jim","age":123})
    end
  end

  describe "#serialize" do
    describe Array do
      describe "of scalar values" do
        assert_serialize_format JSON, [1, 2, 3], "[1,2,3]"
      end

      describe "of mixed types" do
        assert_serialize_format JSON, [false, nil, "foo"], %([false,null,"foo"])
      end

      describe "of hashes" do
        assert_serialize_format JSON, [{"name" => "Jim", :age => 19}, {"name" => "Jim", :age => 18, "value": false}], %([{"name":"Jim","age":19},{"name":"Jim","age":18,"value":false}])
      end
    end

    describe Bool do
      assert_serialize_format JSON, true, "true"
    end

    describe Enum do
      assert_serialize_format JSON, MyEnum::Two, "1"
    end

    describe Hash do
      describe "simple hash" do
        assert_serialize_format JSON, {"name" => "Jim", :age => 19}, %({"name":"Jim","age":19})
      end

      describe "nested hash" do
        assert_serialize_format JSON, {"name" => "Jim", :age => 19, "location": {"address" => "123 fake street", "zip": 90210}}, %({"name":"Jim","age":19,"location":{"address":"123 fake street","zip":90210}})
      end
    end

    describe JSON::Any do
      assert_serialize_format JSON, JSON.parse(%({"name":"Jim","age":19})), %({"name":"Jim","age":19})
    end

    describe NamedTuple do
      assert_serialize_format JSON, {numbers: [1, 2, 3], "data": {"name" => "Jim", :age => 19}}, %({"numbers":[1,2,3],"data":{"name":"Jim","age":19}})
    end

    describe Nil do
      assert_serialize_format JSON, nil, "null"
    end

    describe Number do
      describe Int do
        assert_serialize_format JSON, 123, "123"
      end

      describe Float do
        assert_serialize_format JSON, 3.14, "3.14"
      end
    end

    describe Set do
      assert_serialize_format JSON, Set{1, 2}, "[1,2]"
    end

    describe Slice do
      ptr = Pointer.malloc(9) { |i| ('a'.ord + i).to_u8 }
      assert_serialize_format JSON, Slice.new(ptr, 3), %("YWJj\\n")
    end

    describe String do
      assert_serialize_format JSON, "foo", %("foo")
    end

    describe Symbol do
      assert_serialize_format JSON, :foo, %("foo")
    end

    describe Time do
      assert_serialize_format JSON, Time.utc(2016, 2, 15, 10, 20, 30), %("2016-02-15T10:20:30Z")
    end

    describe Tuple do
      assert_serialize_format JSON, {true, false}, "[true,false]"
    end

    describe UUID do
      assert_serialize_format JSON, UUID.new("f89dc089-2c6c-411a-af20-ea98f90376ef"), %("f89dc089-2c6c-411a-af20-ea98f90376ef")
    end

    describe YAML::Any do
      assert_serialize_format JSON, YAML.parse(%(---\nname: Jim\nage: 19)), %({"name":"Jim","age":19})
    end
  end
end
