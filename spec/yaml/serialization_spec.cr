require "../spec_helper"

describe "YAML" do
  describe "#to_yaml" do
    describe "for various types" do
      it "should serialize correctly" do
        OtherTypesTest.new.to_yaml.should eq %(---\nbool: true\nfloat: 3.14\nsymbol: foo\nhash:\n  foo: bar\ntuple:\n- foo\n- 999\n- 4.321\ntime: 1985-04-12 23:20:50\nset:\n- 1\n- 2\nnamed_tuple:\n  str: foo\n  int: 999\n  float: -4.321\nenum_type: 0\n)
      end
    end

    describe "serialized_name" do
      it "should serialize correctly" do
        SerializedNameTest.new.to_yaml.should eq %(---\nyears_young: 77\n)
      end

      describe "with an array" do
        it "should serialize correctly" do
          [SerializedNameTest.new, SerializedNameTest.new].to_yaml.should eq %(---\n- years_young: 77\n- years_young: 77\n)
          ArrayTest.new.to_yaml.should eq %(---\nnumbers:\n- 1\n- 2\n- 3\n)
        end
      end
    end

    describe "expose" do
      it "should serialize correctly" do
        ExposeTest.new.to_yaml.should eq %(---\nname: John\n)
      end

      describe "with an array" do
        it "should serialize correctly" do
          [ExposeTest.new, ExposeTest.new].to_yaml.should eq %(---\n- name: John\n- name: John\n)
        end
      end

      describe "with YAML:Field#ignore" do
        it "should serialize correctly" do
          YamlFieldTest.new.to_yaml.should eq %(---\nname: John\n)
        end
      end
    end

    describe "emit_null" do
      it "should serialize correctly" do
        model = EmitNullTest.new
        model.name = "John"
        model.im_null = "foo"
        model.to_yaml.should eq %(---\nage: \nname: John\nim_null: foo\n)
      end

      it "should not emit_null by default" do
        model = EmitNullTest.new
        model.name = "John"
        model.to_yaml.should eq %(---\nage: \nname: John\n)
      end

      describe "with an array" do
        it "should serialize correctly" do
          model = EmitNullTest.new
          model.name = "John"
          model.im_null = "foo"
          [model, model].to_yaml.should eq %(---\n- &1\n  age: \n  name: John\n  im_null: foo\n- *1\n)
        end
      end
    end

    describe "accessor" do
      it "should serialize correctly" do
        AccessorTest.new.to_yaml.should eq %(---\nname: JOHN\n)
      end

      describe "with an array" do
        it "should serialize correctly" do
          [AccessorTest.new, AccessorTest.new].to_yaml.should eq %(---\n- name: JOHN\n- name: JOHN\n)
        end
      end
    end

    describe "exclusion_policy" do
      it "should not expose properties by default" do
        ExcludeAlltest.new.to_yaml.should eq %(---\nvalue: foo\n)
      end

      describe "with an array" do
        it "should serialize correctly" do
          [ExcludeAlltest.new, ExcludeAlltest.new].to_yaml.should eq %(---\n- value: foo\n- value: foo\n)
        end
      end
    end

    describe "with a subclass" do
      it "should serialize correctly" do
        SubclassTest.new.to_yaml.should eq %(---\nage: 22\nname: Joe\nfoo:\n  bar: bar\n)
      end
    end

    describe "with an array of objects" do
      it "should serialize correctly" do
        [Foo.new, Foo.new].to_yaml.should eq %(---\n- bar: bar\n- bar: bar\n)
      end

      describe "of mixed types" do
        it "should serialize correctly" do
          [SerializedNameTest.new, ExposeTest.new].to_yaml.should eq %(---\n- years_young: 77\n- name: John\n)
        end
      end
    end

    describe "groups" do
      describe "default group" do
        it "should serialize correctly" do
          GroupsTest.new.to_yaml.should eq %(---\nuser_id: 999\nother_id: 7777\n)
        end
      end

      describe "admin group" do
        it "should serialize correctly" do
          GroupsTest.new.to_yaml(["admin"]).should eq %(---\nadmin_id: 123\nother_id: 7777\n)
        end
      end

      describe "admin + default" do
        it "should serialize correctly" do
          GroupsTest.new.to_yaml(["admin", "default"]).should eq %(---\nuser_id: 999\nadmin_id: 123\nother_id: 7777\n)
        end
      end

      describe "with an array" do
        describe "admin group" do
          it "should serialize correctly" do
            [GroupsTest.new, GroupsTest.new].to_yaml(["admin"]).should eq %(---\n- admin_id: 123\n  other_id: 7777\n- admin_id: 123\n  other_id: 7777\n)
          end
        end
      end
    end

    describe "since/until" do
      describe "with no version set" do
        it "should serialize properties without annotation or nil annotation" do
          VersionsTest.new.to_yaml.should eq %(---\nnone: None\n"null": "null"\n)
        end

        describe "with an array" do
          it "should serialize correctly" do
            [VersionsTest.new, VersionsTest.new].to_yaml.should eq %(---\n- none: None\n  "null": "null"\n- none: None\n  "null": "null"\n)
          end
        end
      end

      describe "with a version set" do
        describe "that is less than the since version" do
          it "should serialize the old name and not the new name" do
            CrSerializer.version = "0.5.0"
            VersionsTest.new.to_yaml.should eq %(---\nold_name: Bobby\nnone: None\n"null": "null"\n)
          end

          describe "with an array" do
            it "should serialize correctly" do
              CrSerializer.version = "0.5.0"
              [VersionsTest.new, VersionsTest.new].to_yaml.should eq %(---\n- old_name: Bobby\n  none: None\n  "null": "null"\n- old_name: Bobby\n  none: None\n  "null": "null"\n)
            end
          end
        end

        describe "that is the since version" do
          it "should serialize the new name but not the old name" do
            CrSerializer.version = "1.0.0"
            VersionsTest.new.to_yaml.should eq %(---\nnew_name: Bob\nnone: None\n"null": "null"\n)
          end

          describe "with an array" do
            it "should serialize correctly" do
              CrSerializer.version = "1.0.0"
              [VersionsTest.new, VersionsTest.new].to_yaml.should eq %(---\n- new_name: Bob\n  none: None\n  "null": "null"\n- new_name: Bob\n  none: None\n  "null": "null"\n)
            end
          end
        end
      end
    end

    describe "expansion" do
      describe "without expansion provided" do
        it "should serialize correctly" do
          ExpandableTest.new.to_yaml.should eq %(---\nname: Foo\n)
        end
      end

      describe "with default values" do
        it "should serialize correctly" do
          ExpandableTest.new.to_yaml(expand: ["customer"]).should eq %(---\nname: Foo\ncustomer:\n  name: MyCust\n  id: 1\n)
        end
      end

      describe "with a custom name" do
        it "should serialize correctly" do
          ExpandableTest.new.to_yaml(expand: ["bar"]).should eq %(---\nname: Foo\nsetting:\n  name: Settings\n  id: 2\n)
        end
      end

      describe "with a custom getter" do
        it "should serialize correctly" do
          ExpandableTest.new.to_yaml(expand: ["custom"]).should eq %(---\nname: Foo\ncustom: 123\n)
        end
      end

      describe "with multiple" do
        it "should serialize correctly" do
          ExpandableTest.new.to_yaml(expand: ["custom", "customer"]).should eq %(---\nname: Foo\ncustomer:\n  name: MyCust\n  id: 1\ncustom: 123\n)
        end
      end
    end

    describe "with a struct" do
      it "should serialize correctly" do
        Config.new.to_yaml.should eq %(---\nrouting:\n  cors:\n    enabled: false\n    strategy: blacklist\n    groups: {}\n)
      end
    end
  end
end
