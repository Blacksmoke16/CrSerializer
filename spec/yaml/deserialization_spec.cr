require "../spec_helper"

describe "YAML" do
  describe ".from_yaml" do
    describe "readonly" do
      it "should deserialize correctly" do
        model = ReadOnlyTest.from_yaml %(---\nname: Secret\nage: 22\npassword: money\nwith_default: true\nno_default: foo)
        model.age.should eq 22
        model.name.should be_nil
        model.with_default.should be_true
        model.no_default.should be_nil
        model.password.should eq "ADefaultPassword"
      end
    end

    describe "with a default value" do
      it "should set the default value" do
        model = DefaultValue.from_yaml %(---\nage: null\n)
        model.age.should eq 99
      end
    end

    describe "with no annotations" do
      it "should deserialize correctly" do
        model = NoAnnotationsTest.from_yaml %(---\nname: Secret\nage: 22\npassword: monkey)
        model.age.should eq 22
        model.name.should eq "Secret"
        model.password.should eq "monkey"
      end
    end

    describe "with a default value" do
      it "should set the default value" do
        Int32.from_yaml("12").should eq 12
      end
    end

    describe "nested classes" do
      describe "without valid assertion" do
        describe "with single objects" do
          describe "when all properties are valid" do
            it "should deserialize correctly" do
              model = NestedTest.from_yaml %(---\nname:\n  n: foo\nage:\n  yrs: 5\n)
              model.age.should be_a Age
              model.age.valid?.should be_true
              model.age.yrs.should eq 5
              model.name.should be_a Name
              model.name.valid?.should be_true
              model.name.n.should eq "foo"
            end
          end

          describe "when a property subclass is invalid" do
            it "should not invalidate parent object" do
              model = NestedTest.from_yaml %(---\nname:\n  n: bar\nage:\n  yrs: 15\n)
              model.valid?.should be_true
              model.age.valid?.should be_false
              model.age.validation_errors.first.should eq "'yrs' should be less than 10"
              model.name.valid?.should be_false
              model.name.validation_errors.first.should eq "'n' should be equal to foo"
            end
          end
        end

        describe "with an array of objects" do
          describe "when all properties are valid" do
            it "should deserialize correctly" do
              model = NestedArrayTest.from_yaml %(---\nname:\n  n: foo\nage:\n  yrs: 5\nfriends:\n  - n: Jim\n  - n: Jim)
              model.valid?.should be_true
              model.age.should be_a Age
              model.age.valid?.should be_true
              model.age.yrs.should eq 5
              model.name.should be_a Name
              model.name.valid?.should be_true
              model.name.n.should eq "foo"
              model.friends.should be_a Array(Friend)
              model.friends[0].valid?.should be_true
              model.friends[0].n.should eq "Jim"
              model.friends[1].valid?.should be_true
              model.friends[1].n.should eq "Jim"
            end
          end

          describe "when a property subclass is invalid" do
            it "should not invalidate parent object" do
              model = NestedArrayTest.from_yaml %(---\nname:\n  n: bar\nage:\n  yrs: 15\nfriends:\n  - n: Bob\n  - n: Jim)
              model.valid?.should be_true
              model.age.valid?.should be_false
              model.age.validation_errors.first.should eq "'yrs' should be less than 10"
              model.name.valid?.should be_false
              model.name.validation_errors.first.should eq "'n' should be equal to foo"
              model.friends[0].valid?.should be_false
              model.friends[0].validation_errors.first.should eq "'n' should be equal to Jim"
              model.friends[1].valid?.should be_true
            end
          end
        end
      end
    end

    describe "with valid assertion" do
      describe "with single objects" do
        describe "when all properties are valid" do
          it "should deserialize correctly and be valid" do
            model = NestedValidTest.from_yaml %(---\nname:\n  n: foo\nage:\n  yrs: 5\n)
            model.age.should be_a Age
            model.age.yrs.should eq 5
            model.name.should be_a Name
            model.name.n.should eq "foo"
          end
        end

        describe "when a property subclass is invalid" do
          it "should invalidate the parent object" do
            model = NestedValidTest.from_yaml %(---\nname:\n  n: bar\nage:\n  yrs: 15\n)
            model.valid?.should be_false
            model.age.valid?.should be_false
            model.age.validation_errors.first.should eq "'yrs' should be less than 10"
            model.name.valid?.should be_false
            model.name.validation_errors.first.should eq "'n' should be equal to foo"
          end
        end

        describe "with an array of objects" do
          describe "when all properties are valid" do
            it "should deserialize correctly" do
              model = NestedArrayValidTest.from_yaml %(---\nname:\n  n: foo\nage:\n  yrs: 5\nfriends:\n  - n: Jim\n  - n: Jim)
              model.valid?.should be_true
              model.age.should be_a Age
              model.age.valid?.should be_true
              model.age.yrs.should eq 5
              model.name.should be_a Name
              model.name.valid?.should be_true
              model.name.n.should eq "foo"
              model.friends.should be_a Array(Friend)
              model.friends[0].valid?.should be_true
              model.friends[0].n.should eq "Jim"
              model.friends[1].valid?.should be_true
              model.friends[1].n.should eq "Jim"
            end
          end
        end

        describe "when a property subclass is invalid" do
          it "should invalidate parent object" do
            model = NestedArrayValidTest.from_yaml %(---\nname:\n  n: bar\nage:\n  yrs: 15\nfriends:\n  - n: Bob\n  - n: Jim)
            model.valid?.should be_false
            model.age.valid?.should be_false
            model.age.validation_errors.first.should eq "'yrs' should be less than 10"
            model.name.valid?.should be_false
            model.name.validation_errors.first.should eq "'n' should be equal to foo"
            model.friends[0].valid?.should be_false
            model.friends[0].validation_errors.first.should eq "'n' should be equal to Jim"
            model.friends[1].valid?.should be_true
          end
        end
      end
    end

    describe "class options" do
      describe "raise_on_invalid" do
        it "should raise correct exception" do
          expect_raises CrSerializer::Exceptions::ValidationException, "Validation tests failed" { RaiseTest.from_yaml %(---\nage: 22) }
        end

        it "should build correct exception object" do
          begin
            RaiseTest.from_yaml %(---\nage: 22)
          rescue ex : CrSerializer::Exceptions::ValidationException
            ex.message.should eq "Validation tests failed"
            ex.to_json.should eq %({"code":400,"message":"Validation tests failed","errors":["'age' should be equal to 10"]})
            ex.to_s.should eq %(Validation tests failed: `'age' should be equal to 10`.)
          end
        end
      end

      describe "validate" do
        it "should not run validations when validate is set to false" do
          model = ValidateTest.from_yaml %(---\nage: 22)
          model.valid?.should be_true
          model.age.should eq 22
        end
      end
    end

    describe "when using a struct" do
      it "should raise on invalid" do
        yaml = %(---\nrouting:\n  cors:\n    enabled: true\n    strategy: Foo)
        ex = expect_raises CrSerializer::Exceptions::ValidationException, "Validation tests failed" { Config.from_yaml yaml }
        ex.to_json.should eq %({"code":400,"message":"Validation tests failed","errors":["'Foo' is not a valid strategy. Valid strategies are: [\\"blacklist\\", \\"whitelist\\"]"]})
        ex.to_s.should eq %(Validation tests failed: `'Foo' is not a valid strategy. Valid strategies are: ["blacklist", "whitelist"]`.)
      end
    end
  end
end
