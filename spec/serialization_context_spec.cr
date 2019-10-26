require "./spec_helper"

struct False < CrSerializer::ExclusionStrategies::ExclusionStrategy
  def initialize; end

  # :inherit:
  def skip_property?(metadata : CrSerializer::PropertyMetadata, context : CrSerializer::Context) : Bool
    false
  end
end

describe CrSerializer::SerializationContext do
  describe "#add_exclusion_strategy" do
    describe "with no previous strategy" do
      it "should set it directly" do
        context = CrSerializer::SerializationContext.new
        context.exclusion_strategy.should be_nil

        context.add_exclusion_strategy False.new

        context.exclusion_strategy.should be_a False
      end
    end

    describe "with a strategy already set" do
      it "should use a Disjunct strategy" do
        context = CrSerializer::SerializationContext.new
        context.exclusion_strategy.should be_nil

        context.add_exclusion_strategy False.new
        context.add_exclusion_strategy False.new

        context.exclusion_strategy.should be_a CrSerializer::ExclusionStrategies::Disjunct
        context.exclusion_strategy.try &.as(CrSerializer::ExclusionStrategies::Disjunct).members.size.should eq 2
      end
    end

    describe "with a multiple strategies already set" do
      it "should push the member to the Disjunct strategy" do
        context = CrSerializer::SerializationContext.new
        context.exclusion_strategy.should be_nil

        context.add_exclusion_strategy False.new
        context.add_exclusion_strategy False.new
        context.add_exclusion_strategy False.new

        context.exclusion_strategy.should be_a CrSerializer::ExclusionStrategies::Disjunct
        context.exclusion_strategy.try &.as(CrSerializer::ExclusionStrategies::Disjunct).members.size.should eq 3
      end
    end
  end

  describe "#groups=" do
    it "sets the groups" do
      context = CrSerializer::SerializationContext.new.groups = ["one", "two"]
      context.groups.should eq ["one", "two"]
    end

    it "raises if the groups are empty" do
      expect_raises ArgumentError, "Groups cannot be empty" do
        CrSerializer::SerializationContext.new.groups = [] of String
      end
    end
  end

  describe "#version=" do
    it "sets the version as a `SemanticVersion`" do
      context = CrSerializer::SerializationContext.new.version = "1.1.1"
      context.version.should eq SemanticVersion.new 1, 1, 1
    end
  end
end
