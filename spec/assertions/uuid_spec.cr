require "../../spec_helper"

class NonStrictUUIDTest
  include CrSerializer

  @[Assert::Uuid(strict: false)]
  property uuid : String?
end

class StrictUUIDTest
  include CrSerializer

  @[Assert::Uuid(strict: true)]
  property uuid : String?
end

class VersionUUIDTest
  include CrSerializer

  @[Assert::Uuid(versions: [UUID::Version::V3, UUID::Version::V4])]
  property uuid : String?
end

class VariantUUIDTest
  include CrSerializer

  @[Assert::Uuid(variants: [UUID::Variant::Future, UUID::Variant::NCS])]
  property uuid : String?
end

class DefaultUUIDTest
  include CrSerializer

  @[Assert::Uuid]
  property uuid : String?
end

class DefaultUUIDTestMessage
  include CrSerializer

  @[Assert::Uuid(message: "{{actual}} is not a valid UUID")]
  property uuid : String?
end

VALID_V1_UUID = [
  "216fff40-98d9-11e3-a5e2-0800200c9a66",
  "216FFF40-98D9-11E3-A5E2-0800200C9A66",
]

VALID_V4_UUID = [
  "456daefb-5aa6-41b5-8dbc-068b05a8b201",
  "456DAEFb-5AA6-41B5-8DBC-068b05a8B201",
]
VALID_NON_STRICT_UUID = [
  "216fff4098d911e3a5e20800200c9a66",
  "urn:uuid:3f9eaf9e-cdb0-45cc-8ecb-0e5b2bfb0c20",
] + VALID_V1_UUID + VALID_V4_UUID

INVALID_NON_STRICT_UUID = [
  "216fff40-98d9-11e3-a5e2_0800200c9a66",
  "216gff40-98d9-11e3-a5e2-0800200c9a66",
  "216Gff40-98d9-11e3-a5e2-0800200c9a66",
  "216fff40-98d9-11e3-a5e2_0800200c9a6",
  "216fff40-98d9-11e3-a5e-20800200c9a66",
  "216fff40-98d9-11e3-a5e2-0800200c9a6",
  "216fff40-98d9-11e3-a5e2-0800200c9a666",
]

VALID_STRICT_UUID = [
  "216fff40-98d9-11e3-a5e2-0800200c9a66",
  "216fff40-98d9-11e3-a5e2-0800200c9a66",
  "216FFF40-98D9-11E3-A5E2-0800200C9A66",
  "456daefb-5aa6-41b5-8dbc-068b05a8b201",
  "456daEFb-5AA6-41B5-8DBC-068B05A8B201",
  "456daEFb-5AA6-41B5-8DBC-068B05A8B201",
]

INVALID_STRICT_UUID = [
  "216fff40-98d9-11e3-a5e2_0800200c9a66",
  "216gff40-98d9-11e3-a5e2-0800200c9a66",
  "216Gff40-98d9-11e3-a5e2-0800200c9a66",
  "216fff40-98d9-11e3-a5e-20800200c9a66",
  "216f-ff40-98d9-11e3-a5e2-0800200c9a66",
  "216fff40-98d9-11e3-a5e2-0800-200c9a66",
  "216fff40-98d9-11e3-a5e2-0800200c-9a66",
  "216fff40-98d9-11e3-a5e20800200c9a66",
  "216fff4098d911e3a5e20800200c9a66",
  "216fff40-98d9-11e3-a5e2-0800200c9a6",
  "216fff40-98d9-11e3-a5e2-0800200c9a666",
  "216fff40-98d9-01e3-a5e2-0800200c9a66",
  "216fff40-98d9-61e3-a5e2-0800200c9a66",
  "216fff40-98d9-71e3-a5e2-0800200c9a66",
  "216fff40-98d9-81e3-a5e2-0800200c9a66",
  "216fff40-98d9-91e3-a5e2-0800200c9a66",
  "216fff40-98d9-a1e3-a5e2-0800200c9a66",
  "216fff40-98d9-b1e3-a5e2-0800200c9a66",
  "216fff40-98d9-c1e3-a5e2-0800200c9a66",
  "216fff40-98d9-d1e3-a5e2-0800200c9a66",
  "216fff40-98d9-e1e3-a5e2-0800200c9a66",
  "216fff40-98d9-f1e3-a5e2-0800200c9a66",
  "216fff40-98d9-11e3-05e2-0800200c9a66",
  "216fff40-98d9-11e3-15e2-0800200c9a66",
  "216fff40-98d9-11e3-25e2-0800200c9a66",
  "216fff40-98d9-11e3-35e2-0800200c9a66",
  "216fff40-98d9-11e3-45e2-0800200c9a66",
  "216fff40-98d9-11e3-55e2-0800200c9a66",
  "216fff40-98d9-11e3-65e2-0800200c9a66",
  "216fff40-98d9-11e3-75e2-0800200c9a66",
  "216fff40-98d9-11e3-c5e2-0800200c9a66",
  "216fff40-98d9-11e3-d5e2-0800200c9a66",
  "216fff40-98d9-11e3-e5e2-0800200c9a66",
  "216fff40-98d9-11e3-f5e2-0800200c9a66",
  "[216fff40-98d9-11e3-a5e2-0800200c9a66]",
  "{216fff40-98d9-11e3-a5e2-0800200c9a66}",
  "urn:uuid:3f9eaf9e-cdb0-45cc-8ecb-0e5b2bfb0c20",
  "216f-ff40-98d9-11e3-a5e2-0800-200c-9a66",
  "216fff40-98d911e3-a5e20800-200c9a66",
]

INVALID_OTHER_VARIANT_UUID = [
  "216fff40-98d9-11e3-a5e2-0800200c9a66",
  "216fff40-98d9-11e3-a5e2-0800200c9a66",
  "216FFF40-98D9-11E3-A5E2-0800200C9A66",
]

VALID_OTHER_VARIANT_UUID = [
  "216fff40-98d9-11e3-45e2-0800200c9a66",
  "216fff40-98d9-11e3-e5e2-0800200c9a66",
]

describe Assert::Uuid do
  describe "non strict" do
    context "invalid UUIDs" do
      it "should all be invalid" do
        INVALID_NON_STRICT_UUID.each do |uuid|
          model = StrictUUIDTest.from_json(%({"uuid": "#{uuid}"}))
          model.validator.valid?.should be_false
          model.validator.errors.size.should eq 1
          model.validator.errors.first.should eq "'uuid' is not a valid UUID"
        end
      end
    end

    context "valid UUIDs" do
      it "should all be valid" do
        VALID_NON_STRICT_UUID.each do |uuid|
          NonStrictUUIDTest.from_json(%({"uuid": "#{uuid}"})).validator.valid?.should be_true
        end
      end
    end
  end

  describe "strict" do
    context "invalid UUIDs" do
      it "should all be invalid" do
        INVALID_STRICT_UUID.each do |uuid|
          model = StrictUUIDTest.from_json(%({"uuid": "#{uuid}"}))
          model.validator.valid?.should be_false
          model.validator.errors.size.should eq 1
          model.validator.errors.first.should eq "'uuid' is not a valid UUID"
        end
      end
    end

    context "valid UUIDs" do
      it "should all be valid" do
        VALID_STRICT_UUID.each do |uuid|
          StrictUUIDTest.from_json(%({"uuid": "#{uuid}"})).validator.valid?.should be_true
        end
      end
    end
  end

  describe "custom versions" do
    context "invalid UUIDs" do
      it "should all be invalid" do
        VALID_V1_UUID.each do |uuid|
          model = VersionUUIDTest.from_json(%({"uuid": "#{uuid}"}))
          model.validator.valid?.should be_false
          model.validator.errors.size.should eq 1
          model.validator.errors.first.should eq "'uuid' is not a valid UUID"
        end
      end
    end

    context "valid UUIDs" do
      it "should all be valid" do
        VALID_V4_UUID.each do |uuid|
          VersionUUIDTest.from_json(%({"uuid": "#{uuid}"})).validator.valid?.should be_true
        end
      end
    end
  end

  describe "custom variants" do
    context "invalid UUIDs" do
      it "should all be invalid" do
        INVALID_OTHER_VARIANT_UUID.each do |uuid|
          model = VariantUUIDTest.from_json(%({"uuid": "#{uuid}"}))
          model.validator.valid?.should be_false
          model.validator.errors.size.should eq 1
          model.validator.errors.first.should eq "'uuid' is not a valid UUID"
        end
      end
    end

    context "valid UUIDs" do
      it "should all be valid" do
        VALID_OTHER_VARIANT_UUID.each do |uuid|
          VariantUUIDTest.from_json(%({"uuid": "#{uuid}"})).validator.valid?.should be_true
        end
      end
    end
  end

  describe "default" do
    context "with valid UUIDs" do
      it "should all be valid" do
        VALID_NON_STRICT_UUID.each do |uuid|
          DefaultUUIDTest.from_json(%({"uuid": "#{uuid}"})).validator.valid?.should be_true
        end
      end
    end

    context "with invalid urls" do
      context "without a custom message" do
        it "should all be invalid" do
          INVALID_NON_STRICT_UUID.each do |uuid|
            model = DefaultUUIDTest.from_json(%({"uuid": "#{uuid}"}))
            model.validator.valid?.should be_false
            model.validator.errors.size.should eq 1
            model.validator.errors.first.should eq "'uuid' is not a valid UUID"
          end
        end
      end

      context "with a custom message" do
        it "should return proper error message" do
          INVALID_NON_STRICT_UUID.each do |uuid|
            model = DefaultUUIDTestMessage.from_json(%({"uuid": "#{uuid}"}))
            model.validator.valid?.should be_false
            model.validator.errors.size.should eq 1
            model.validator.errors.first.should eq "#{uuid} is not a valid UUID"
          end
        end
      end
    end

    context "with null urls" do
      it "should be valid" do
        DefaultUUIDTest.from_json(%({"uuid": null})).validator.valid?.should be_true
      end
    end
  end
end
