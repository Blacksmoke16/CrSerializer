require "../spec_helper"

describe "JSON" do
  describe ".from_json" do
    describe "readonly" do
      it "should deserialize correctly" do
        model = ReadOnlyTest.from_json %({"name":"Secret","age":22,"password":"monkey"})
        model.age.should eq 22
        model.name.should be_nil
        model.password.should eq "ADefaultPassword"
      end
    end

    describe "with a default value" do
      it "should set the default value" do
        model = DefaultValue.from_json %({"age": null})
        model.age.should eq 99
      end
    end

    describe "with no annotations" do
      it "should deserialize correctly" do
        model = NoAnnotationsTest.from_json %({"name":"Secret","age":22,"password":"monkey"})
        model.age.should eq 22
        model.name.should eq "Secret"
        model.password.should eq "monkey"
      end
    end

    describe "with a default value" do
      it "should set the default value" do
        Int32.from_json("12").should eq 12
      end
    end

    describe "nested classes" do
      context "without valid assertion" do
        context "with single objects" do
          describe "when all properties are valid" do
            it "should deserialize correctly" do
              model = NestedTest.from_json %({"name":{"n": "foo"},"age":{"yrs": 5}})
              model.age.should be_a Age
              model.age.valid?.should be_true
              model.age.yrs.should eq 5
              model.name.should be_a Name
              model.name.valid?.should be_true
              model.name.n.should eq "foo"
            end
          end

          describe "when a proeprty subclass is invalid" do
            it "should not invalidate parent object" do
              model = NestedTest.from_json %({"name":{"n": "bar"},"age":{"yrs": 15}})
              model.valid?.should be_true
              model.age.valid?.should be_false
              model.age.validation_errors.first.should eq "'yrs' should be less than 10"
              model.name.valid?.should be_false
              model.name.validation_errors.first.should eq "'n' should be equal to foo"
            end
          end
        end

        context "with an array of objects" do
          describe "when all properties are valid" do
            it "should deserialize correctly" do
              model = NestedArrayTest.from_json %({"name":{"n": "foo"},"age":{"yrs": 5},"friends":[{"n":"Jim"},{"n":"Jim"}]})
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

          describe "when a proeprty subclass is invalid" do
            it "should not invalidate parent object" do
              model = NestedArrayTest.from_json %({"name":{"n": "bar"},"age":{"yrs": 15},"friends":[{"n":"Bob"},{"n":"Jim"}]})
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

      context "with valid assertion" do
        context "with single objects" do
          describe "when all properties are valid" do
            it "should deserialize correctly and be valid" do
              model = NestedValidTest.from_json %({"name":{"n": "foo"},"age":{"yrs": 5}})
              model.age.should be_a Age
              model.age.yrs.should eq 5
              model.name.should be_a Name
              model.name.n.should eq "foo"
            end
          end

          describe "when a proeprty subclass is invalid" do
            it "should invalidate the parent object" do
              model = NestedValidTest.from_json %({"name":{"n": "bar"},"age":{"yrs": 15}})
              model.valid?.should be_false
              model.age.valid?.should be_false
              model.age.validation_errors.first.should eq "'yrs' should be less than 10"
              model.name.valid?.should be_false
              model.name.validation_errors.first.should eq "'n' should be equal to foo"
            end
          end
        end

        context "with an array of objects" do
          describe "when all properties are valid" do
            it "should deserialize correctly" do
              model = NestedArrayValidTest.from_json %({"name":{"n": "foo"},"age":{"yrs": 5},"friends":[{"n":"Jim"},{"n":"Jim"}]})
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

          describe "when a proeprty subclass is invalid" do
            it "should invalidate parent object" do
              model = NestedArrayValidTest.from_json %({"name":{"n": "bar"},"age":{"yrs": 15},"friends":[{"n":"Bob"},{"n":"Jim"}]})
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
    end

    describe "class options" do
      describe "raise_on_invalid" do
        it "should raise correct exception" do
          expect_raises CrSerializer::Exceptions::ValidationException, "Validation tests failed" { RaiseTest.from_json %({"age":22}) }
        end

        it "should build correct exception object" do
          begin
            RaiseTest.from_json %({"age":22})
          rescue ex : CrSerializer::Exceptions::ValidationException
            ex.message.should eq "Validation tests failed"
            ex.to_json.should eq %({"code":400,"message":"Validation tests failed","errors":["'age' should be equal to 10"]})
            ex.to_s.should eq %(Validation tests failed: `'age' should be equal to 10`.)
          end
        end
      end

      describe "validate" do
        it "should not run validations when validate is set to false" do
          model = ValidateTest.from_json %({"age":22})
          model.valid?.should be_true
          model.age.should eq 22
        end
      end
    end

    describe "when using a struct" do
      it "should raise on invalid" do
        json = %({"routing": {"cors": {"enabled": true, "strategy": "Foo"}}})
        ex = expect_raises CrSerializer::Exceptions::ValidationException, "Validation tests failed" { Config.from_json json }
        ex.to_json.should eq %({"code":400,"message":"Validation tests failed","errors":["'Foo' is not a valid strategy. Valid strategies are: [\\"blacklist\\", \\"whitelist\\"]"]})
        ex.to_s.should eq %(Validation tests failed: `'Foo' is not a valid strategy. Valid strategies are: ["blacklist", "whitelist"]`.)
      end
    end
  end
end
