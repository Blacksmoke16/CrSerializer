require "./spec_helper"

describe CRS do
  describe ".deserialize" do
    describe CRS::Groups do
      describe "without any groups in the context" do
        it "should include all properties" do
          TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), _context : CrSerializer::Context) do
            properties.size.should eq 4

            p = properties[0]

            p.name.should eq "id"
            p.external_name.should eq "id"
            p.groups.should eq ["list", "details"]

            p = properties[1]

            p.name.should eq "comment_summaries"
            p.external_name.should eq "comment_summaries"
            p.groups.should eq ["list"]

            p = properties[2]

            p.name.should eq "comments"
            p.external_name.should eq "comments"
            p.groups.should eq ["details"]

            p = properties[3]

            p.name.should eq "created_at"
            p.external_name.should eq "created_at"
            p.groups.should eq ["default"]
          end

          Group.deserialize TEST, ""
        end
      end

      describe "with a group specified" do
        it "should exclude properties not in the given groups" do
          TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), _context : CrSerializer::Context) do
            properties.size.should eq 2

            p = properties[0]

            p.name.should eq "id"
            p.external_name.should eq "id"
            p.groups.should eq ["list", "details"]

            p = properties[1]

            p.name.should eq "comment_summaries"
            p.external_name.should eq "comment_summaries"
            p.groups.should eq ["list"]
          end

          Group.deserialize TEST, "", CrSerializer::DeserializationContext.new.groups = ["list"]
        end
      end

      describe "that is in the default group" do
        it "should include properties without groups explicitally defined" do
          TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), _context : CrSerializer::Context) do
            properties.size.should eq 3

            p = properties[0]

            p.name.should eq "id"
            p.external_name.should eq "id"
            p.groups.should eq ["list", "details"]

            p = properties[1]

            p.name.should eq "comment_summaries"
            p.external_name.should eq "comment_summaries"
            p.groups.should eq ["list"]

            p = properties[2]

            p.name.should eq "created_at"
            p.external_name.should eq "created_at"
            p.groups.should eq ["default"]
          end

          Group.deserialize TEST, "", CrSerializer::DeserializationContext.new.groups = ["list", "default"]
        end
      end
    end

    describe CRS::PostDeserialize do
      it "should run pre serialize methods" do
        TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), _context : CrSerializer::Context) do
          properties.size.should eq 1

          p = properties[0]

          p.name.should eq "name"
          p.external_name.should eq "name"

          nil
        end

        obj = PostDeserialize.deserialize TEST, ""
        obj.name.should eq "First Last"
        obj.first_name.should eq "First"
        obj.last_name.should eq "Last"
      end
    end
  end

  describe ".deserialization_properties" do
    pending CRS::Accessor do
      it "should set the value with the method" do
      end
    end

    describe CRS::Discriminator do
    end

    describe CRS::ExclusionPolicy do
      describe :all do
        describe CRS::Expose do
          it "should only return properties that are exposed" do
            properties = Expose.deserialization_properties
            properties.size.should eq 1

            p = properties[0]

            p.name.should eq "name"
            p.external_name.should eq "name"
          end
        end
      end

      describe :none do
        describe CRS::Exclude do
          it "should only return properties that are not excluded" do
            properties = Exclude.deserialization_properties
            properties.size.should eq 1

            p = properties[0]

            p.name.should eq "name"
            p.external_name.should eq "name"
          end
        end
      end
    end

    describe CRS::Name do
      describe :deserialize do
        it "should use the value in the annotation or property name if it wasnt defined" do
          properties = DeserializedName.deserialization_properties
          properties.size.should eq 2

          p = properties[0]

          p.name.should eq "custom_name"
          p.external_name.should eq "des"
          p.aliases.should eq [] of String

          p = properties[1]

          p.name.should eq "default_name"
          p.external_name.should eq "default_name"
          p.aliases.should eq [] of String
        end
      end

      describe :aliases do
        it "should set the aliases" do
          properties = AliasName.deserialization_properties
          properties.size.should eq 1

          p = properties[0]

          p.name.should eq "some_value"
          p.external_name.should eq "some_value"
          p.aliases.should eq ["val", "value", "some_value"]
        end
      end
    end

    describe CRS::ReadOnly do
      it "should not include read-only properties" do
        properties = ReadOnly.deserialization_properties
        properties.size.should eq 1

        p = properties[0]

        p.name.should eq "name"
        p.external_name.should eq "name"
      end
    end

    describe CRS::Skip do
      it "should not include skipped properties" do
        properties = Skip.deserialization_properties
        properties.size.should eq 1

        p = properties[0]

        p.name.should eq "one"
        p.external_name.should eq "one"
      end
    end
  end

  describe "#serialize" do
    describe CRS::PreSerialize do
      it "should run pre serialize methods" do
        obj = PreSerialize.new
        obj.name.should be_nil
        obj.age.should be_nil

        TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), _context : CrSerializer::Context) do
          properties.size.should eq 2
          p = properties[0]

          p.name.should eq "name"
          p.external_name.should eq "name"
          p.value.should eq "NAME"
          p.skip_when_empty?.should be_false
          p.groups.should eq ["default"] of String
          p.type.should eq String?
          p.class.should eq PreSerialize

          p = properties[1]

          p.name.should eq "age"
          p.external_name.should eq "age"
          p.value.should eq 123
          p.skip_when_empty?.should be_false
          p.groups.should eq ["default"] of String
          p.type.should eq Int32?
          p.class.should eq PreSerialize
        end

        obj.serialize TEST

        obj.name.should eq "NAME"
        obj.age.should eq 123
      end
    end

    describe CRS::PostSerialize do
      it "should run pre serialize methods" do
        obj = PostSerialize.new
        obj.name.should be_nil
        obj.age.should be_nil

        TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), _context : CrSerializer::Context) do
          properties.size.should eq 2
          p = properties[0]

          p.name.should eq "name"
          p.external_name.should eq "name"
          p.value.should eq "NAME"
          p.skip_when_empty?.should be_false
          p.groups.should eq ["default"] of String
          p.type.should eq String?
          p.class.should eq PostSerialize

          p = properties[1]

          p.name.should eq "age"
          p.external_name.should eq "age"
          p.value.should eq 123
          p.skip_when_empty?.should be_false
          p.groups.should eq ["default"] of String
          p.type.should eq Int32?
          p.class.should eq PostSerialize
        end

        obj.serialize TEST

        obj.name.should be_nil
        obj.age.should be_nil
      end
    end

    describe CRS::SkipWhenEmpty do
      it "should not serialize empty properties" do
        obj = SkipWhenEmpty.new
        obj.value = ""

        TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), _context : CrSerializer::Context) do
          properties.should be_empty
        end

        obj.serialize TEST
      end

      it "should serialize non-empty properties" do
        obj = SkipWhenEmpty.new

        TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), _context : CrSerializer::Context) do
          properties.size.should eq 1
          p = properties[0]

          p.name.should eq "value"
          p.external_name.should eq "value"
          p.value.should eq "value"
          p.skip_when_empty?.should be_true
          p.groups.should eq ["default"] of String
          p.type.should eq String
          p.class.should eq SkipWhenEmpty
        end

        obj.serialize TEST
      end
    end

    describe :emit_nil do
      describe "with the default value" do
        it "should not include nil values" do
          obj = EmitNil.new

          TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), context : CrSerializer::Context) do
            context.as(CrSerializer::SerializationContext).emit_nil?.should be_false

            properties.size.should eq 1
            p = properties[0]

            p.name.should eq "age"
            p.external_name.should eq "age"
            p.value.should eq 1
            p.skip_when_empty?.should be_false
            p.groups.should eq ["default"] of String
            p.type.should eq Int32
            p.class.should eq EmitNil
          end

          obj.serialize TEST
        end
      end

      describe "when enabled" do
        it "should include nil values" do
          obj = EmitNil.new
          ctx = CrSerializer::SerializationContext.new
          ctx.emit_nil = true

          TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), context : CrSerializer::Context) do
            context.as(CrSerializer::SerializationContext).emit_nil?.should be_true

            properties.size.should eq 2
            p = properties[0]

            p.name.should eq "name"
            p.external_name.should eq "name"
            p.value.should eq nil
            p.skip_when_empty?.should be_false
            p.groups.should eq ["default"] of String
            p.type.should eq String?
            p.class.should eq EmitNil

            p = properties[1]

            p.name.should eq "age"
            p.external_name.should eq "age"
            p.value.should eq 1
            p.skip_when_empty?.should be_false
            p.groups.should eq ["default"] of String
            p.type.should eq Int32
            p.class.should eq EmitNil
          end

          obj.serialize TEST, ctx
        end
      end
    end

    describe CRS::Groups do
      describe "without any groups in the context" do
        it "should include all properties" do
          obj = Group.new

          TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), _context : CrSerializer::Context) do
            properties.size.should eq 4

            p = properties[0]

            p.name.should eq "id"
            p.external_name.should eq "id"
            p.value.should eq 1
            p.skip_when_empty?.should be_false
            p.groups.should eq ["list", "details"]
            p.type.should eq Int64
            p.class.should eq Group

            p = properties[1]

            p.name.should eq "comment_summaries"
            p.external_name.should eq "comment_summaries"
            p.value.should eq ["Sentence 1.", "Sentence 2."]
            p.skip_when_empty?.should be_false
            p.groups.should eq ["list"]
            p.type.should eq Array(String)
            p.class.should eq Group

            p = properties[2]

            p.name.should eq "comments"
            p.external_name.should eq "comments"
            p.value.should eq ["Sentence 1.  Another sentence.", "Sentence 2.  Some other stuff."]
            p.skip_when_empty?.should be_false
            p.groups.should eq ["details"]
            p.type.should eq Array(String)
            p.class.should eq Group

            p = properties[3]

            p.name.should eq "created_at"
            p.external_name.should eq "created_at"
            p.value.should eq Time.utc(2019, 1, 1)
            p.skip_when_empty?.should be_false
            p.groups.should eq ["default"]
            p.type.should eq Time
            p.class.should eq Group
          end

          obj.serialize TEST
        end
      end

      describe "with a group specified" do
        it "should exclude properties not in the given groups" do
          obj = Group.new

          TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), _context : CrSerializer::Context) do
            properties.size.should eq 2

            p = properties[0]

            p.name.should eq "id"
            p.external_name.should eq "id"
            p.value.should eq 1
            p.skip_when_empty?.should be_false
            p.groups.should eq ["list", "details"]
            p.type.should eq Int64
            p.class.should eq Group

            p = properties[1]

            p.name.should eq "comment_summaries"
            p.external_name.should eq "comment_summaries"
            p.value.should eq ["Sentence 1.", "Sentence 2."]
            p.skip_when_empty?.should be_false
            p.groups.should eq ["list"]
            p.type.should eq Array(String)
            p.class.should eq Group
          end

          obj.serialize TEST, CrSerializer::SerializationContext.new.groups = ["list"]
        end
      end

      describe "that is in the default group" do
        it "should include properties without groups explicitally defined" do
          obj = Group.new

          TEST.assert_properties = ->(properties : Array(CrSerializer::Metadata), _context : CrSerializer::Context) do
            properties.size.should eq 3

            p = properties[0]

            p.name.should eq "id"
            p.external_name.should eq "id"
            p.value.should eq 1
            p.skip_when_empty?.should be_false
            p.groups.should eq ["list", "details"]
            p.type.should eq Int64
            p.class.should eq Group

            p = properties[1]

            p.name.should eq "comment_summaries"
            p.external_name.should eq "comment_summaries"
            p.value.should eq ["Sentence 1.", "Sentence 2."]
            p.skip_when_empty?.should be_false
            p.groups.should eq ["list"]
            p.type.should eq Array(String)
            p.class.should eq Group

            p = properties[2]

            p.name.should eq "created_at"
            p.external_name.should eq "created_at"
            p.value.should eq Time.utc(2019, 1, 1)
            p.skip_when_empty?.should be_false
            p.groups.should eq ["default"]
            p.type.should eq Time
            p.class.should eq Group
          end

          obj.serialize TEST, CrSerializer::SerializationContext.new.groups = ["list", "default"]
        end
      end
    end
  end

  describe "#serialization_properties" do
    describe CRS::Accessor do
      it "should use the value of the method" do
        properties = Accessor.new.serialization_properties
        properties.size.should eq 1

        p = properties[0]

        p.name.should eq "foo"
        p.external_name.should eq "foo"
        p.value.should eq "FOO"
        p.skip_when_empty?.should be_false
        p.type.should eq String
        p.class.should eq Accessor
      end
    end

    describe CRS::AccessorOrder do
      describe :default do
        it "should used the order in which the properties were defined" do
          properties = Default.new.serialization_properties
          properties.size.should eq 6

          properties.map(&.name).should eq %w(a z two one a_a get_val)
          properties.map(&.external_name).should eq %w(a z two one a_a get_val)
        end
      end

      describe :alphabetical do
        it "should order the properties alphabetically by their name" do
          properties = Abc.new.serialization_properties
          properties.size.should eq 6

          properties.map(&.name).should eq %w(a a_a get_val one zzz z)
          properties.map(&.external_name).should eq %w(a a_a get_val one two z)
        end
      end

      describe :custom do
        it "should use the order defined by the user" do
          properties = Custom.new.serialization_properties
          properties.size.should eq 6

          properties.map(&.name).should eq %w(two z get_val a one a_a)
          properties.map(&.external_name).should eq %w(two z get_val a one a_a)
        end
      end
    end

    describe CRS::Skip do
      it "should not include skipped properties" do
        properties = Skip.new.serialization_properties
        properties.size.should eq 1

        p = properties[0]

        p.name.should eq "one"
        p.external_name.should eq "one"
        p.value.should eq "one"
        p.skip_when_empty?.should be_false
        p.type.should eq String
        p.class.should eq Skip
      end
    end

    describe CRS::ExclusionPolicy do
      describe :all do
        describe CRS::Expose do
          it "should only return properties that are exposed" do
            properties = Expose.new.serialization_properties
            properties.size.should eq 1

            p = properties[0]

            p.name.should eq "name"
            p.external_name.should eq "name"
            p.value.should eq "Jim"
            p.skip_when_empty?.should be_false
            p.type.should eq String
            p.class.should eq Expose
          end
        end
      end

      describe :none do
        describe CRS::Exclude do
          it "should only return properties that are not excluded" do
            properties = Exclude.new.serialization_properties
            properties.size.should eq 1

            p = properties[0]

            p.name.should eq "name"
            p.external_name.should eq "name"
            p.value.should eq "Jim"
            p.skip_when_empty?.should be_false
            p.type.should eq String
            p.class.should eq Exclude
          end
        end
      end
    end

    describe CRS::Name do
      describe :serialize do
        it "should use the value in the annotation or property name if it wasnt defined" do
          properties = SerializedName.new.serialization_properties
          properties.size.should eq 3

          p = properties[0]

          p.name.should eq "my_home_address"
          p.external_name.should eq "myAddress"
          p.value.should eq "123 Fake Street"
          p.skip_when_empty?.should be_false
          p.type.should eq String
          p.class.should eq SerializedName

          p = properties[1]

          p.name.should eq "value"
          p.external_name.should eq "a_value"
          p.value.should eq "str"
          p.skip_when_empty?.should be_false
          p.type.should eq String
          p.class.should eq SerializedName

          p = properties[2]

          p.name.should eq "myZipCode"
          p.external_name.should eq "myZipCode"
          p.value.should eq 90210
          p.skip_when_empty?.should be_false
          p.type.should eq Int32
          p.class.should eq SerializedName
        end
      end
    end

    describe CRS::SkipWhenEmpty do
      it "should use the value of the method" do
        properties = SkipWhenEmpty.new.serialization_properties
        properties.size.should eq 1

        p = properties[0]

        p.name.should eq "value"
        p.external_name.should eq "value"
        p.value.should eq "value"
        p.skip_when_empty?.should be_true
        p.type.should eq String
        p.class.should eq SkipWhenEmpty
      end
    end

    describe CRS::VirtualProperty do
      it "should only return properties that are not excluded" do
        properties = VirtualProperty.new.serialization_properties
        properties.size.should eq 2

        p = properties[0]

        p.name.should eq "foo"
        p.external_name.should eq "foo"
        p.value.should eq "foo"
        p.skip_when_empty?.should be_false
        p.type.should eq String
        p.class.should eq VirtualProperty

        p = properties[1]

        p.name.should eq "get_val"
        p.external_name.should eq "get_val"
        p.value.should eq "VAL"
        p.skip_when_empty?.should be_false
        p.type.should eq String
        p.class.should eq VirtualProperty
      end
    end
  end
end
