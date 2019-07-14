class ReadOnlyTest
  include CrSerializer(JSON | YAML)

  property age : Int32

  @[CrSerializer::Options(readonly: true)]
  property name : String?

  @[CrSerializer::Options(readonly: true)]
  property with_default : Bool = true

  @[CrSerializer::Options(readonly: true)]
  property no_default : String?

  @[CrSerializer::Options(readonly: true)]
  property password : String = "ADefaultPassword"
end

class NoAnnotationsTest
  include CrSerializer(JSON | YAML)

  property age : Int32
  property name : String
  property password : String
end

class NestedTest
  include CrSerializer(JSON | YAML)

  property name : Name

  property age : Age
end

class NestedArrayTest
  include CrSerializer(JSON | YAML)

  property name : Name

  property age : Age

  property friends : Array(Friend)
end

class NestedValidTest
  include CrSerializer(JSON | YAML)

  @[Assert::Valid]
  property name : Name

  property age : Age
end

class NestedArrayValidTest
  include CrSerializer(JSON | YAML)

  property name : Name

  property age : Age

  @[Assert::Valid]
  property friends : Array(Friend)
end

class Age
  include CrSerializer(JSON | YAML)

  @[Assert::LessThan(value: 10)]
  property yrs : Int32?
end

class Name
  include CrSerializer(JSON | YAML)

  @[Assert::EqualTo(value: "foo")]
  property n : String
end

class Friend
  include CrSerializer(JSON | YAML)

  @[Assert::EqualTo(value: "Jim")]
  property n : String
end

@[CrSerializer::ClassOptions(raise_on_invalid: true)]
class RaiseTest
  include CrSerializer(JSON | YAML)

  @[Assert::EqualTo(value: 10)]
  property age : Int32
end

@[CrSerializer::ClassOptions(validate: false)]
class ValidateTest
  include CrSerializer(JSON | YAML)

  # def initialize; end

  @[Assert::EqualTo(value: 10)]
  property age : Int32
end

class DefaultValue
  include CrSerializer(JSON | YAML)

  def initialize; end

  @[Assert::GreaterThan(value: 0)]
  @[Assert::NotNil]
  property age : Int32 = 99
end

class SerializedNameTest
  include CrSerializer(JSON | YAML)

  def initialize; end

  @[CrSerializer::Options(serialized_name: "years_young")]
  property age : Int32 = 77
end

class ExposeTest
  include CrSerializer(JSON | YAML)

  def initialize; end

  @[CrSerializer::Options(expose: false)]
  property age : Int32 = 66

  property name : String = "John"
end

class JsonFieldTest
  include CrSerializer(JSON | YAML)

  def initialize; end

  @[JSON::Field(ignore: true)]
  property age : Int32 = 66

  property name : String = "John"
end

class YamlFieldTest
  include CrSerializer(JSON | YAML)

  def initialize; end

  @[YAML::Field(ignore: true)]
  property age : Int32 = 66

  property name : String = "John"
end

class EmitNullTest
  include CrSerializer(JSON | YAML)

  def initialize; end

  @[CrSerializer::Options(emit_null: true)]
  property age : Int32?

  property name : String = "John"

  property im_null : String? = nil
end

class AccessorTest
  include CrSerializer(JSON | YAML)

  def initialize; end

  @[CrSerializer::Options(accessor: get_name)]
  property name : String = "John"

  def get_name : String
    @name.upcase
  end
end

class GroupsTest
  include CrSerializer(JSON | YAML)

  def initialize; end

  property user_id : Int32 = 999

  @[CrSerializer::Options(groups: ["admin"])]
  property admin_id : Int32 = 123

  @[CrSerializer::Options(groups: ["admin", "default"])]
  property other_id : Int32 = 7777
end

class VersionsTest
  include CrSerializer(JSON | YAML)

  def initialize; end

  @[CrSerializer::Options(since: "1.0.0")]
  property new_name : String = "Bob"

  @[CrSerializer::Options(until: "1.0.0")]
  property old_name : String = "Bobby"

  property none : String = "None"

  @[CrSerializer::Options(until: nil)]
  property null : String = "null"
end

@[CrSerializer::ClassOptions(exclusion_policy: CrSerializer::ExclusionPolicy::ExcludeAll)]
class ExcludeAlltest
  include CrSerializer(JSON | YAML)

  def initialize; end

  property age : Int32 = 22
  property name : String = "Joe"

  @[CrSerializer::Options(expose: true)]
  property value : String = "foo"
end

class SubclassTest
  include CrSerializer(JSON | YAML)

  def initialize; end

  property age : Int32 = 22
  property name : String = "Joe"

  property foo : Foo = Foo.new
end

class Foo
  include CrSerializer(JSON | YAML)

  def initialize; end

  @[CrSerializer::Options(serialized_name: "bar")]
  property sub_class : String = "bar"
end

class ArrayTest
  include CrSerializer(JSON | YAML)

  def initialize; end

  property numbers : Array(Int32) = [1, 2, 3]
end

class OtherTypesTest
  include CrSerializer(JSON | YAML)

  def initialize; end

  property bool : Bool = true
  property float : Float64 = 3.14
  property symbol : Symbol = :foo
  property set = Set{1, 2}
  property hash : Hash(String, String) = {"foo" => "bar"}
  property tuple : Tuple(String, Int32, Float32) = {"foo", 999, 4.321_f32}
  property named_tuple = {str: "foo", int: 999, float: -4.321_f32}
  property enum_type = CrSerializer::ExclusionPolicy::ExcludeAll
  property time : Time = Time.utc(1985, 4, 12, 23, 20, 50)
end

class Customer
  include CrSerializer(JSON | YAML)

  def initialize; end

  property name : String = "MyCust"
  property id : Int32 = 1
end

class Setting
  include CrSerializer(JSON | YAML)

  def initialize; end

  property name : String = "Settings"
  property id : Int32 = 2
end

class ExpandableTest
  include CrSerializer(JSON | YAML)

  def initialize; end

  property name : String = "Foo"

  @[CrSerializer::Expandable]
  property customer : Customer?

  @[CrSerializer::Expandable(name: "bar")]
  property setting : Setting?

  @[CrSerializer::Expandable(getter: my_function)]
  property custom : Int32?

  def customer : Customer
    Customer.new
  end

  def setting : Setting
    Setting.new
  end

  def my_function
    123
  end
end

struct Config
  include CrSerializer(JSON | YAML)

  def initialize; end

  getter routing : RoutingConfig = RoutingConfig.new
end

struct RoutingConfig
  include CrSerializer(JSON | YAML)

  def initialize; end

  getter cors : CorsConfig = CorsConfig.new
end

@[CrSerializer::ClassOptions(raise_on_invalid: true)]
struct CorsConfig
  include CrSerializer(JSON | YAML)

  def initialize; end

  getter enabled : Bool = false

  @[Assert::Choice(choices: ["blacklist", "whitelist"], message: "'{{actual}}' is not a valid strategy. Valid strategies are: {{choices}}")]
  getter strategy : String = "blacklist"

  getter groups : Hash(String, CorsOptions) = {} of String => CorsOptions
end

struct CorsOptions
  include CrSerializer(JSON | YAML)

  def initialize; end
end
