require "../../spec_helper"

class EmailHTML5Test
  include CrSerializer

  @[Assert::Email(mode: CrSerializer::Assertions::EmailValidationMode::HTML5)]
  property email : String?
end

class EmailLOOSETest
  include CrSerializer

  @[Assert::Email(mode: CrSerializer::Assertions::EmailValidationMode::LOOSE)]
  property email : String?
end

class EmailDefaultTest
  include CrSerializer

  @[Assert::Email]
  property email : String?
end

class EmailDefaultTestMessage
  include CrSerializer

  @[Assert::Email(message: "Invalid Email")]
  property email : String?
end

VALID_LOOSE_EMAILS = [
  "blacksmoke16@eve.tools",
  "example@example.co.uk",
  "fabien_potencier@example.fr",
  "example@example.co..uk",
  "{}~!@!@£$%%^&*().!@£$%^&*()",
  "example@example.co..uk",
  "example@-example.com",
  "example@#{"a"*64}.com",
]

INVALID_LOOSE_EMAILS = [
  "example",
  "example@",
  "example@localhost",
  "foo@example.com bar",
]

VALID_HTML5_EMAILS = [
  "blacksmoke16@eve.tools",
  "example@example.co.uk",
  "blacksmoke_blacksmoke@example.fr",
  "{}~!@example.com",
]

INVALID_HTML5_EMAILS = [
  "example",
  "example@",
  "example@localhost",
  "example@example.co..uk",
  "foo@example.com bar",
  "example@example.",
  "example@.fr",
  "@example.com",
  "example@example.com;example@example.com",
  "example@.",
  " example@example.com",
  "example@ ",
  " example@example.com ",
  " example @example .com ",
  "example@-example.com",
  "example@#{"a"*64}.com",
]

describe Assert::Email do
  describe CrSerializer::Assertions::EmailValidationMode::HTML5 do
    context "with valid emails" do
      it "should all be valid" do
        VALID_HTML5_EMAILS.each do |email|
          EmailHTML5Test.deserialize(%({"email": "#{email}"})).validator.valid?.should be_true
        end
      end
    end

    context "with invalid emails" do
      it "should all be invalid" do
        INVALID_HTML5_EMAILS.each do |email|
          model = EmailHTML5Test.deserialize(%({"email": "#{email}"}))
          model.validator.valid?.should be_false
          model.validator.errors.size.should eq 1
          model.validator.errors.first.should eq "'email' is not a valid email address"
        end
      end
    end

    context "with null email" do
      it "should be valid" do
        EmailHTML5Test.deserialize(%({"email": null})).validator.valid?.should be_true
      end
    end
  end

  describe CrSerializer::Assertions::EmailValidationMode::LOOSE do
    context "with valid emails" do
      it "should all be valid" do
        VALID_LOOSE_EMAILS.each do |email|
          EmailLOOSETest.deserialize(%({"email": "#{email}"})).validator.valid?.should be_true
        end
      end
    end

    context "with invalid emails" do
      it "should all be invalid" do
        INVALID_LOOSE_EMAILS.each do |email|
          model = EmailLOOSETest.deserialize(%({"email": "#{email}"}))
          model.validator.valid?.should be_false
          model.validator.errors.size.should eq 1
          model.validator.errors.first.should eq "'email' is not a valid email address"
        end
      end
    end

    context "with null email" do
      it "should be valid" do
        EmailLOOSETest.deserialize(%({"email": null})).validator.valid?.should be_true
      end
    end
  end

  describe "default" do
    context "with valid emails" do
      it "should all be valid" do
        VALID_LOOSE_EMAILS.each do |email|
          EmailDefaultTest.deserialize(%({"email": "#{email}"})).validator.valid?.should be_true
        end
      end
    end

    context "with invalid emails" do
      context "without a custom message" do
        it "should all be invalid" do
          INVALID_LOOSE_EMAILS.each do |email|
            model = EmailDefaultTest.deserialize(%({"email": "#{email}"}))
            model.validator.valid?.should be_false
            model.validator.errors.size.should eq 1
            model.validator.errors.first.should eq "'email' is not a valid email address"
          end
        end
      end

      context "with a custom message" do
        it "should return proper error message" do
          INVALID_LOOSE_EMAILS.each do |email|
            model = EmailDefaultTestMessage.deserialize(%({"email": "#{email}"}))
            model.validator.valid?.should be_false
            model.validator.errors.size.should eq 1
            model.validator.errors.first.should eq "Invalid Email"
          end
        end
      end
    end

    context "with null email" do
      it "should be valid" do
        EmailDefaultTest.deserialize(%({"email": null})).validator.valid?.should be_true
      end
    end
  end
end
