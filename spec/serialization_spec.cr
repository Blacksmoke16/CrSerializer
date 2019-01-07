require "./spec_helper"

class SerializedNameTest
  include CrSerializer

  @[CrSerializer::Options(serialized_name: "years_young")]
  property age : Int32 = 77
end

class ExposeTest
  include CrSerializer

  @[CrSerializer::Options(expose: false)]
  property age : Int32 = 66

  property name : String = "John"
end

class JsonFieldTest
  include CrSerializer

  @[JSON::Field(ignore: true)]
  property age : Int32 = 66

  property name : String = "John"
end

class EmitNullTest
  include CrSerializer

  @[CrSerializer::Options(emit_null: true)]
  property age : Int32?

  property name : String

  property im_null : String? = nil
end

class AccessorTest
  include CrSerializer

  @[CrSerializer::Options(accessor: get_name)]
  property name : String = "John"

  def get_name : String
    @name.upcase
  end
end

class GroupsTest
  include CrSerializer

  property user_id : Int32 = 999

  @[CrSerializer::Options(groups: ["admin"])]
  property admin_id : Int32 = 123

  @[CrSerializer::Options(groups: ["admin", "default"])]
  property other_id : Int32 = 7777
end

class VersionsTest
  include CrSerializer

  @[CrSerializer::Options(since: "1.0.0")]
  property new_name : String = "Bob"

  @[CrSerializer::Options(until: "1.0.0")]
  property old_name : String = "Bobby"

  property none : String = "None"

  @[CrSerializer::Options(until: nil)]
  property null : String = "null"
end

@[CrSerializer::ClassOptions(exclusion_policy: CrSerializer::ExclusionPolicy::EXCLUDE_ALL)]
class ExcludeAlltest
  include CrSerializer

  property age : Int32 = 22
  property name : String = "Joe"

  @[CrSerializer::Options(expose: true)]
  property value : String = "foo"
end

class SubclassTest
  include CrSerializer

  property age : Int32 = 22
  property name : String = "Joe"

  property foo : Foo = Foo.new
end

class Foo
  include CrSerializer

  @[CrSerializer::Options(serialized_name: "bar")]
  property sub_class : String = "bar"
end

class ArrayTest
  include CrSerializer

  property numbers : Array(Int32) = [1, 2, 3]
end

describe "serialize" do
  describe "serialized_name" do
    it "should serialize correctly" do
      SerializedNameTest.new.serialize.should eq %({"years_young":77})
    end

    describe "with an array" do
      it "should serialize correctly" do
        [SerializedNameTest.new, SerializedNameTest.new].serialize.should eq %([{"years_young":77},{"years_young":77}])
        ArrayTest.new.serialize.should eq %({"numbers":[1,2,3]})
      end
    end
  end

  describe "expose" do
    it "should serialize correctly" do
      ExposeTest.new.serialize.should eq %({"name":"John"})
    end

    describe "with an array" do
      it "should serialize correctly" do
        [ExposeTest.new, ExposeTest.new].serialize.should eq %([{"name":"John"},{"name":"John"}])
      end
    end

    describe "with JSON:Field#ignore" do
      it "should serialize correctly" do
        JsonFieldTest.new.serialize.should eq %({"name":"John"})
      end
    end
  end

  describe "emit_null" do
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

    describe "with an array" do
      it "should serialize correctly" do
        model = EmitNullTest.new
        model.name = "John"
        model.im_null = "foo"
        [model, model].serialize.should eq %([{"age":null,"name":"John","im_null":"foo"},{"age":null,"name":"John","im_null":"foo"}])
      end
    end
  end

  describe "accessor" do
    it "should serialize correctly" do
      AccessorTest.new.serialize.should eq %({"name":"JOHN"})
    end

    describe "with an array" do
      it "should serialize correctly" do
        [AccessorTest.new, AccessorTest.new].serialize.should eq %([{"name":"JOHN"},{"name":"JOHN"}])
      end
    end
  end

  describe "exclusion_policy" do
    it "should not expose properties by default" do
      ExcludeAlltest.new.serialize.should eq %({"value":"foo"})
    end

    describe "with an array" do
      it "should serialize correctly" do
        [ExcludeAlltest.new, ExcludeAlltest.new].serialize.should eq %([{"value":"foo"},{"value":"foo"}])
      end
    end
  end

  describe "with a subclass" do
    it "should serialize correctly" do
      SubclassTest.new.serialize.should eq %({"age":22,"name":"Joe","foo":{"bar":"bar"}})
    end
  end

  describe "with an array of objects" do
    it "should serialize correctly" do
      [Foo.new, Foo.new].serialize.should eq %([{"bar":"bar"},{"bar":"bar"}])
    end

    describe "of mixed types" do
      it "should serialize correctly" do
        [SerializedNameTest.new, ExposeTest.new].serialize.should eq %([{"years_young":77},{"name":"John"}])
      end
    end
  end

  describe "groups" do
    describe "default group" do
      it "should serialize correctly" do
        GroupsTest.new.serialize.should eq %({"user_id":999,"other_id":7777})
      end
    end

    describe "admin group" do
      it "should serialize correctly" do
        GroupsTest.new.serialize(["admin"]).should eq %({"admin_id":123,"other_id":7777})
      end
    end

    describe "admin + default" do
      it "should serialize correctly" do
        GroupsTest.new.serialize(["admin", "default"]).should eq %({"user_id":999,"admin_id":123,"other_id":7777})
      end
    end

    describe "with an array" do
      describe "admin group" do
        it "should serialize correctly" do
          [GroupsTest.new, GroupsTest.new].serialize(["admin"]).should eq %([{"admin_id":123,"other_id":7777},{"admin_id":123,"other_id":7777}])
        end
      end
    end
  end

  describe "since/until" do
    context "with no version set" do
      it "should serialize properties without annotation or nil annotation" do
        VersionsTest.new.serialize.should eq %({"none":"None","null":"null"})
      end

      describe "with an array" do
        it "should serialize correctly" do
          [VersionsTest.new, VersionsTest.new].serialize.should eq %([{"none":"None","null":"null"},{"none":"None","null":"null"}])
        end
      end
    end

    context "with a version set" do
      describe "that is less than the since version" do
        CrSerializer.version = "0.5.0"

        it "should serialize the old name and not the new name" do
          VersionsTest.new.serialize.should eq %({"old_name":"Bobby","none":"None","null":"null"})
        end

        describe "with an array" do
          it "should serialize correctly" do
            [VersionsTest.new, VersionsTest.new].serialize.should eq %([{"old_name":"Bobby","none":"None","null":"null"},{"old_name":"Bobby","none":"None","null":"null"}])
          end
        end
      end

      describe "that is the since version" do
        CrSerializer.version = "1.0.0"

        it "should serialize the new name but not the old name" do
          VersionsTest.new.serialize.should eq %({"new_name":"Bob","none":"None","null":"null"})
        end

        describe "with an array" do
          it "should serialize correctly" do
            [VersionsTest.new, VersionsTest.new].serialize.should eq %([{"new_name":"Bob","none":"None","null":"null"},{"new_name":"Bob","none":"None","null":"null"}])
          end
        end
      end
    end
  end
end
