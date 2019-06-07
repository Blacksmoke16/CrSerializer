require "../spec_helper"

class RegexMatchTest
  include CrSerializer(JSON | YAML)

  @[Assert::RegexMatch(pattern: /foo==bar/)]
  property name_match : String?

  @[Assert::RegexMatch(pattern: /foo==bar/, match: false)]
  property name_not_match : String
end

class RegexMatchTestMessage
  include CrSerializer(JSON | YAML)

  @[Assert::RegexMatch(message: "Expected {{field}} to match {{pattern}}", pattern: /foo==bar/)]
  property name : String
end

describe Assert::RegexMatch do
  it "should be valid" do
    model = RegexMatchTest.from_json(%({"name_match": "foo==bar", "name_not_match": "foo..bar"}))
    model.valid?.should be_true
  end

  describe "with invalid properties" do
    it "should be invalid" do
      model = RegexMatchTest.from_json(%({"name_match": "foo.=bar", "name_not_match": "foo==bar"}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 2
      model.validation_errors[0].should eq "'name_match' is not valid"
      model.validation_errors[1].should eq "'name_not_match' is not valid"
    end
  end

  describe "with null property" do
    it "should be valid" do
      model = RegexMatchTest.from_json(%({"name_match": null, "name_not_match": "foo..bar"}))
      model.valid?.should be_true
    end
  end

  describe "with a custom message" do
    it "should use correct message" do
      model = RegexMatchTestMessage.from_json(%({"name":"Joe"}))
      model.valid?.should be_false
      model.validation_errors.size.should eq 1
      model.validation_errors.first.should eq "Expected name to match (?-imsx:foo==bar)"
    end
  end
end
