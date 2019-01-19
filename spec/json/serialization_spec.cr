require "../spec_helper"

describe "JSON" do
  describe "#to_json" do
    describe "for various types" do
      it "should serialize correctly" do
        OtherTypesTest.new.to_json.should eq %({"bool":true,"float":3.14,"symbol":"foo","hash":{"foo":"bar"},"tuple":["foo",999,4.321],"time":"1985-04-12T23:20:50Z","set":[1,2],"named_tuple":{"str":"foo","int":999,"float":-4.321},"enum_type":0})
      end
    end

    describe "serialized_name" do
      it "should serialize correctly" do
        SerializedNameTest.new.to_json.should eq %({"years_young":77})
      end

      describe "with an array" do
        it "should serialize correctly" do
          [SerializedNameTest.new, SerializedNameTest.new].to_json.should eq %([{"years_young":77},{"years_young":77}])
          ArrayTest.new.to_json.should eq %({"numbers":[1,2,3]})
        end
      end
    end

    describe "expose" do
      it "should serialize correctly" do
        ExposeTest.new.to_json.should eq %({"name":"John"})
      end

      describe "with an array" do
        it "should serialize correctly" do
          [ExposeTest.new, ExposeTest.new].to_json.should eq %([{"name":"John"},{"name":"John"}])
        end
      end

      describe "with JSON:Field#ignore" do
        it "should serialize correctly" do
          JsonFieldTest.new.to_json.should eq %({"name":"John"})
        end
      end
    end

    describe "emit_null" do
      it "should serialize correctly" do
        model = EmitNullTest.new
        model.name = "John"
        model.im_null = "foo"
        model.to_json.should eq %({"age":null,"name":"John","im_null":"foo"})
      end

      it "should not emit_null by default" do
        model = EmitNullTest.new
        model.name = "John"
        model.to_json.should eq %({"age":null,"name":"John"})
      end

      describe "with an array" do
        it "should serialize correctly" do
          model = EmitNullTest.new
          model.name = "John"
          model.im_null = "foo"
          [model, model].to_json.should eq %([{"age":null,"name":"John","im_null":"foo"},{"age":null,"name":"John","im_null":"foo"}])
        end
      end
    end

    describe "accessor" do
      it "should serialize correctly" do
        AccessorTest.new.to_json.should eq %({"name":"JOHN"})
      end

      describe "with an array" do
        it "should serialize correctly" do
          [AccessorTest.new, AccessorTest.new].to_json.should eq %([{"name":"JOHN"},{"name":"JOHN"}])
        end
      end
    end

    describe "exclusion_policy" do
      it "should not expose properties by default" do
        ExcludeAlltest.new.to_json.should eq %({"value":"foo"})
      end

      describe "with an array" do
        it "should serialize correctly" do
          [ExcludeAlltest.new, ExcludeAlltest.new].to_json.should eq %([{"value":"foo"},{"value":"foo"}])
        end
      end
    end

    describe "with a subclass" do
      it "should serialize correctly" do
        SubclassTest.new.to_json.should eq %({"age":22,"name":"Joe","foo":{"bar":"bar"}})
      end
    end

    describe "with an array of objects" do
      it "should serialize correctly" do
        [Foo.new, Foo.new].to_json.should eq %([{"bar":"bar"},{"bar":"bar"}])
      end

      describe "of mixed types" do
        it "should serialize correctly" do
          [SerializedNameTest.new, ExposeTest.new].to_json.should eq %([{"years_young":77},{"name":"John"}])
        end
      end
    end

    describe "groups" do
      describe "default group" do
        it "should serialize correctly" do
          GroupsTest.new.to_json.should eq %({"user_id":999,"other_id":7777})
        end
      end

      describe "admin group" do
        it "should serialize correctly" do
          GroupsTest.new.to_json(["admin"]).should eq %({"admin_id":123,"other_id":7777})
        end
      end

      describe "admin + default" do
        it "should serialize correctly" do
          GroupsTest.new.to_json(["admin", "default"]).should eq %({"user_id":999,"admin_id":123,"other_id":7777})
        end
      end

      describe "with an array" do
        describe "admin group" do
          it "should serialize correctly" do
            [GroupsTest.new, GroupsTest.new].to_json(["admin"]).should eq %([{"admin_id":123,"other_id":7777},{"admin_id":123,"other_id":7777}])
          end
        end
      end
    end

    describe "since/until" do
      context "with no version set" do
        it "should serialize properties without annotation or nil annotation" do
          VersionsTest.new.to_json.should eq %({"none":"None","null":"null"})
        end

        describe "with an array" do
          it "should serialize correctly" do
            [VersionsTest.new, VersionsTest.new].to_json.should eq %([{"none":"None","null":"null"},{"none":"None","null":"null"}])
          end
        end
      end

      context "with a version set" do
        describe "that is less than the since version" do
          it "should serialize the old name and not the new name" do
            CrSerializer.version = "0.5.0"
            VersionsTest.new.to_json.should eq %({"old_name":"Bobby","none":"None","null":"null"})
          end

          describe "with an array" do
            it "should serialize correctly" do
              CrSerializer.version = "0.5.0"
              [VersionsTest.new, VersionsTest.new].to_json.should eq %([{"old_name":"Bobby","none":"None","null":"null"},{"old_name":"Bobby","none":"None","null":"null"}])
            end
          end
        end

        describe "that is the since version" do
          it "should serialize the new name but not the old name" do
            CrSerializer.version = "1.0.0"
            VersionsTest.new.to_json.should eq %({"new_name":"Bob","none":"None","null":"null"})
          end

          describe "with an array" do
            it "should serialize correctly" do
              CrSerializer.version = "1.0.0"
              [VersionsTest.new, VersionsTest.new].to_json.should eq %([{"new_name":"Bob","none":"None","null":"null"},{"new_name":"Bob","none":"None","null":"null"}])
            end
          end
        end
      end
    end

    describe "expansion" do
      describe "without expansion provided" do
        it "should serialize correctly" do
          ExpandableTest.new.to_json.should eq %({"name":"Foo"})
        end
      end

      describe "with default values" do
        it "should serialize correctly" do
          ExpandableTest.new.to_json(expand: ["customer"]).should eq %({"name":"Foo","customer":{"name":"MyCust","id":1}})
        end
      end

      describe "with a custom name" do
        it "should serialize correctly" do
          ExpandableTest.new.to_json(expand: ["bar"]).should eq %({"name":"Foo","setting":{"name":"Settings","id":2}})
        end
      end

      describe "with a custom getter" do
        it "should serialize correctly" do
          ExpandableTest.new.to_json(expand: ["custom"]).should eq %({"name":"Foo","custom":123})
        end
      end

      describe "with multiple" do
        it "should serialize correctly" do
          ExpandableTest.new.to_json(expand: ["custom", "customer"]).should eq %({"name":"Foo","customer":{"name":"MyCust","id":1},"custom":123})
        end
      end
    end
  end

  describe "#to_pretty_json" do
    it "should serialize in pretty form" do
      OtherTypesTest.new.to_pretty_json.should eq %({\n  \"bool\": true,\n  \"float\": 3.14,\n  \"symbol\": \"foo\",\n  \"hash\": {\n    \"foo\": \"bar\"\n  },\n  \"tuple\": [\n    \"foo\",\n    999,\n    4.321\n  ],\n  \"time\": \"1985-04-12T23:20:50Z\",\n  \"set\": [\n    1,\n    2\n  ],\n  \"named_tuple\": {\n    \"str\": \"foo\",\n    \"int\": 999,\n    \"float\": -4.321\n  },\n  \"enum_type\": 0\n})
    end

    describe "groups" do
      describe "default group" do
        it "should serialize correctly" do
          GroupsTest.new.to_pretty_json.should eq %({\n  "user_id": 999,\n  "other_id": 7777\n})
        end
      end

      describe "admin group" do
        it "should serialize correctly" do
          GroupsTest.new.to_pretty_json(groups: ["admin"]).should eq %({\n  "admin_id": 123,\n  "other_id": 7777\n})
        end
      end

      describe "admin + default" do
        it "should serialize correctly" do
          GroupsTest.new.to_pretty_json(groups: ["admin", "default"]).should eq %({\n  "user_id": 999,\n  "admin_id": 123,\n  "other_id": 7777\n})
        end
      end

      describe "with an array" do
        describe "admin group" do
          it "should serialize correctly" do
            [GroupsTest.new, GroupsTest.new].to_pretty_json(groups: ["admin"]).should eq %([\n  {\n    \"admin_id\": 123,\n    \"other_id\": 7777\n  },\n  {\n    \"admin_id\": 123,\n    \"other_id\": 7777\n  }\n])
          end
        end
      end
    end

    describe "expansion" do
      describe "without expansion provided" do
        it "should serialize correctly" do
          ExpandableTest.new.to_pretty_json.should eq %({\n  "name": "Foo"\n})
        end
      end

      describe "with default values" do
        it "should serialize correctly" do
          ExpandableTest.new.to_pretty_json(expand: ["customer"]).should eq %({\n  \"name\": \"Foo\",\n  \"customer\": {\n    \"name\": \"MyCust\",\n    \"id\": 1\n  }\n})
        end
      end

      describe "with a custom name" do
        it "should serialize correctly" do
          ExpandableTest.new.to_pretty_json(expand: ["bar"]).should eq %({\n  \"name\": \"Foo\",\n  \"setting\": {\n    \"name\": \"Settings\",\n    \"id\": 2\n  }\n})
        end
      end

      describe "with a custom getter" do
        it "should serialize correctly" do
          ExpandableTest.new.to_pretty_json(expand: ["custom"]).should eq %({\n  \"name\": \"Foo\",\n  \"custom\": 123\n})
        end
      end

      describe "with multiple" do
        it "should serialize correctly" do
          ExpandableTest.new.to_pretty_json(expand: ["custom", "customer"]).should eq %({\n  \"name\": \"Foo\",\n  \"customer\": {\n    \"name\": \"MyCust\",\n    \"id\": 1\n  },\n  \"custom\": 123\n})
        end
      end
    end
  end
end
