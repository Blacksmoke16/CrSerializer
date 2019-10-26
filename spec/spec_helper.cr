require "spec"
require "../src/CrSerializer"
require "./models/*"

private DEFAULT_PROC = ->(_properties : Array(CrSerializer::Metadata), _context : CrSerializer::Context) {}

enum MyEnum
  One
  Two
end

class SomeObj
end

class TestObject
  include CrSerializer

  def initialize(@name : String, @age : Int32?); end

  @[CRS::Name(serialize: "the_name", deserialize: "some_name")]
  getter name : String
  getter age : Int32?

  @[CRS::Skip]
  getter initialized : Bool = false

  @[CRS::PostDeserialize]
  def set_initialized : Nil
    @initialized = true
  end
end

module CrSerializer
  def serialization_properties
    previous_def
  end
end

# Test module for format agnostic testing of serialization/deserialization features.
#
# Can define a proc that will yield the properties and context passed to `.serialize`.
module TEST
  include CrSerializer::Format

  class_setter assert_properties : Proc(Array(CrSerializer::Metadata), CrSerializer::Context, Nil) = DEFAULT_PROC

  def self.deserialize(type : _, properties : Array(CrSerializer::Metadata), string_or_io : String | IO, context : CrSerializer::Context)
    @@assert_properties.call properties, context
    type.new
  end

  def self.serialize(properties : Array(CrSerializer::Metadata), context : CrSerializer::Context) : String
    @@assert_properties.call properties, context
    ""
  end
end

macro assert_deserialize_format(format, type, input, output)
  it "should serialize correctly" do
    {{type}}.deserialize({{format}}, {{input}}).should eq {{output}}
  end
end

macro assert_serialize_format(format, input, output)
  it "should serialize correctly" do
    {{input}}.serialize({{format}}).should eq {{output}}
  end
end

def create_metadata(*, name : String = "name", external_name : String = "external_name", value : I = "value", skip_when_empty : Bool = false, groups : Array(String) = ["default"], since_version : String? = nil, until_version : String? = nil) : CrSerializer::PropertyMetadata forall I
  context = CrSerializer::PropertyMetadata(I, SomeObj).new name, external_name, value, skip_when_empty, groups

  context.since_version = SemanticVersion.parse since_version if since_version
  context.until_version = SemanticVersion.parse until_version if until_version

  context
end

def assert_version(*, since_version : String? = nil, until_version : String? = nil) : Bool
  CrSerializer::ExclusionStrategies::Version.new(SemanticVersion.parse "1.0.0").skip_property?(create_metadata(since_version: since_version, until_version: until_version), CrSerializer::SerializationContext.new)
end

def assert_groups(*, groups : Array(String), metadata_groups : Array(String) = ["default"]) : Bool
  CrSerializer::ExclusionStrategies::Groups.new(groups).skip_property?(create_metadata(groups: metadata_groups), CrSerializer::SerializationContext.new)
end

Spec.before_each { TEST.assert_properties = DEFAULT_PROC }
