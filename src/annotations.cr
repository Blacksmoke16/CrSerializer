# [CrSerializer](./index.html) uses annotations to control how an object gets serialized and deserialized.
# This module includes all the default serialization and deserialization annotations. The `CRS` alias can be used as a shorthand when applying the annotations.
module CrSerializer::Annotations
  # Defines the method to use to get/set the property's value.
  #
  # TODO: Implement `setter`.
  #
  # ```
  # class Example
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   @[CRS::Accessor(getter: get_foo)]
  #   property foo : String = "foo"
  #
  #   private def get_foo : String
  #     @foo.upcase
  #   end
  # end
  #
  # Example.new.serialize JSON # => {"foo":"FOO"}
  # ```
  annotation Accessor; end

  # Defines the order of properties within a class/struct.  Valid values: `:alphabetical`, and `:custom`.
  #
  # By default properties are ordered in the order in which they were defined.
  # ```
  # class Default
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   property a : String = "A"
  #   property z : String = "Z"
  #   property two : String = "two"
  #   property one : String = "one"
  #   property a_a : Int32 = 123
  #
  #   @[CRS::VirtualProperty]
  #   def get_val : String
  #     "VAL"
  #   end
  # end
  #
  # Default.new.to_json # => {"a":"A","z":"Z","two":"two","one":"one","a_a":123,"get_val":"VAL"}
  #
  # @[CRS::AccessorOrder(:alphabetical)]
  # class Abc
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   property a : String = "A"
  #   property z : String = "Z"
  #   property two : String = "two"
  #   property one : String = "one"
  #   property a_a : Int32 = 123
  #
  #   @[CRS::VirtualProperty]
  #   def get_val : String
  #     "VAL"
  #   end
  # end
  #
  # Abc.new.to_json # => {"a":"A","a_a":123,"get_val":"VAL","one":"one","two":"two","z":"Z"}
  #
  # @[CRS::AccessorOrder(:custom, order: ["two", "z", "get_val", "a", "one", "a_a"])]
  # class Custom
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   property a : String = "A"
  #   property z : String = "Z"
  #   property two : String = "two"
  #   property one : String = "one"
  #   property a_a : Int32 = 123
  #
  #   @[CRS::VirtualProperty]
  #   def get_val : String
  #     "VAL"
  #   end
  # end
  #
  # Custom.new.to_json # => {"two":"two","z":"Z","get_val":"VAL","a":"A","one":"one","a_a":123}
  # ```
  annotation AccessorOrder; end

  # TODO: Implement this.
  annotation Discriminator; end

  # Indicates that a property should not be serialized/deserialized when used with `CrSerializer::ExclusionPolicy::None`.
  #
  # Also see, `CRS::IgnoreOnDeserialize` and `CRS::IgnoreOnSerialize`.
  # ```
  # @[CRS::ExclusionPolicy(:none)]
  # class Example
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   property name : String = "Jim"
  #
  #   @[CRS::Exclude]
  #   property password : String? = "monkey"
  # end
  #
  # Example.new.to_json # => {"name":"Jim"}
  # ```
  annotation Exclude; end

  # Defines the default exclusion policy to use on a class.  Valid values: `:none`, and `:all`.
  #
  # Used with `CRS::Expose` and `CRS::Exclude`.
  #
  # See`CrSerializer::ExclusionPolicy`.
  annotation ExclusionPolicy; end

  # Indicates that a property should be serialized/deserialized when used with `CrSerializer::ExclusionPolicy::All`.
  #
  # ```
  # @[CRS::ExclusionPolicy(:all)]
  # class Example
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   @[CRS::Expose]
  #   property name : String = "Jim"
  #
  #   property password : String? = "monkey"
  # end
  #
  # Example.new.to_json # => {"name":"Jim"}
  # ```
  annotation Expose; end

  # Defines the group(s) a property belongs to.  Properties are automatically added to the `default` group
  # if no groups are explicitly defined.
  #
  # See `CrSerializer::ExclusionStrategies::Groups`.
  annotation Groups; end

  # Indicates that a property should not be set on deserialization, but should be serialized.
  #
  # ```
  # class Example
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   property name : String
  #
  #   @[CRS::IgnoreOnDeserialize]
  #   property password : String?
  # end
  #
  # obj = Example.deserialize %({"name":"Jim","password":"monkey123"})
  #
  # obj.password # => nil
  #
  # obj.password = "foobar"
  #
  # obj.to_json # => {"name":"Jim","password":"foobar"}
  # ```
  annotation IgnoreOnDeserialize; end

  # Indicates that a property should be set on deserialization, but should not be serialized.
  #
  # ```
  # class Example
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   property name : String
  #
  #   @[CRS::IgnoreOnSerialize]
  #   property password : String
  # end
  #
  # obj = Example.from_json %({"name":"Jim","password":"monkey123"})
  #
  # obj.password # => "monkey123"
  #
  # obj.to_json # => {"name":"Jim"}
  # ```
  annotation IgnoreOnSerialize; end

  # Defines a callback method(s) that are ran directly before the object is serialized.
  #
  # ```
  # @[CRS::ExclusionPolicy(:all)]
  # class Example
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   @[CRS::Expose]
  #   private getter name : String?
  #
  #   property first_name : String = "Jon"
  #   property last_name : String = "Snow"
  #
  #   @[CRS::PreSerialize]
  #   def pre_ser : Nil
  #     @name = "#{first_name} #{last_name}"
  #   end
  #
  #   @[CRS::PostSerialize]
  #   def post_ser : Nil
  #     @name = nil
  #   end
  # end
  #
  # Example.new.to_json # => {"name":"Jon Snow"}
  # ```
  annotation PreSerialize; end

  # Defines a callback method(s) that are ran directly after the object has been serialized.
  #
  # ```
  # @[CRS::ExclusionPolicy(:all)]
  # class Example
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   @[CRS::Expose]
  #   private getter name : String?
  #
  #   property first_name : String = "Jon"
  #   property last_name : String = "Snow"
  #
  #   @[CRS::PreSerialize]
  #   def pre_ser : Nil
  #     @name = "#{first_name} #{last_name}"
  #   end
  #
  #   @[CRS::PostSerialize]
  #   def post_ser : Nil
  #     @name = nil
  #   end
  # end
  #
  # Example.new.to_json # => {"name":"Jon Snow"}
  # ```
  annotation PostSerialize; end

  # Defines a callback method(s) that are ran directly after the object has been deserialized.
  #
  # ```
  # record Example, name : String, first_name : String?, last_name : String? do
  #   include CrSerializer
  #
  #   @[CRS::PostDeserialize]
  #   def split_name : Nil
  #     @first_name, @last_name = @name.split(' ')
  #   end
  # end
  #
  # obj = Example.deserialize JSON, %({"name":"Jon Snow"})
  # obj.name       # => Jon Snow
  # obj.first_name # => Jon
  # obj.last_name  # => Snow
  # ```
  annotation PostDeserialize; end

  # Indicates that a property is read-only and cannot be set during deserialization.
  #
  # NOTE: The property must be nilable or have a default value.
  # ```
  # class ReadOnly
  #   include CrSerializer
  #
  #   property name : String
  #
  #   @[CRS::ReadOnly]
  #   property password : String?
  # end
  #
  # obj = ReadOnly.from_json %({"name":"Fred","password":"password1"})
  # obj.name     # => "Fred"
  # obj.password # => nil
  # ```
  annotation ReadOnly; end

  # Defines the name to use on deserialization and serialization.  If not provided, the name defaults to the name of the property.
  # Also allows defining aliases that can be used for that property when deserializing.
  #
  # ```
  # class Example
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   @[CRS::Name(serialize: "myAddress")]
  #   property my_home_address : String = "123 Fake Street"
  #
  #   @[CRS::Name(deserialize: "some_key", serialize: "a_value")]
  #   property both_names : String = "str"
  #
  #   @[CRS::Name(aliases: ["val", "value", "some_value"])]
  #   property some_value : String? = "some_val"
  # end
  #
  # Example.new.to_json # => {"myAddress":"123 Fake Street","a_value":"str","some_value":"some_val"}
  # obj = Example.from_json %({"my_home_address":"555 Mason Ave","some_key":"deserialized from diff key","value":"some_other_val"})
  # obj.my_home_address # => "555 Mason Ave"
  # obj.both_names      # => "deserialized from diff key"
  # obj.some_value      # => "some_other_val"
  # ```
  annotation Name; end

  # Represents the first version a property was available.
  #
  # See `CrSerializer::ExclusionStrategies::Version`.
  # NOTE: Value must be a `SemanticVersion` version.
  annotation Since; end

  # Indicates that a property should not be serialized or deserialized.
  #
  # ```
  # class Example
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   property name : String = "Jim"
  #
  #   @[CRS::Skip]
  #   property password : String? = "monkey"
  # end
  #
  # Example.new.to_json # => {"name":"Fred"}
  # ```
  annotation Skip; end

  # Indicates that a property should not be serialized when it is empty.
  #
  # NOTE: Can be used on any type that defines an `#empty?` method.
  # ```
  # class SkipWhenEmpty
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   property id : Int64 = 1
  #
  #   @[CRS::SkipWhenEmpty]
  #   property value : String = "value"
  #
  #   @[CRS::SkipWhenEmpty]
  #   property values : Array(String) = %w(one two three)
  # end
  #
  # obj = SkipWhenEmpty.new
  # obj.to_json # => {"id":1,"value":"value","values":["one","two","three"]}
  #
  # obj.value = ""
  # obj.values = [] of String
  #
  # obj.to_json # => {"id":1}
  # ```
  annotation SkipWhenEmpty; end

  # Represents the last version a property was available.
  #
  # See `CrSerializer::ExclusionStrategies::Version`.
  # NOTE: Value must be a `SemanticVersion` version.
  annotation Until; end

  # Can be applied to a method to make it act like a property.
  # ```
  # class Example
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   property foo : String = "foo"
  #
  #   property bar : String = "bar"
  #
  #   @[CRS::VirtualProperty]
  #   @[CRS::SerializedName("testing")]
  #   def some_method : Bool
  #     false
  #   end
  #
  #   @[CRS::VirtualProperty]
  #   def get_val : String
  #     "VAL"
  #   end
  # end
  #
  # Example.new.serialize JSON # => {"foo":"foo","bar":"bar","testing":false,"get_val":"VAL"}
  # ```
  # NOTE: The return type restriction _MUST_ be defined.
  annotation VirtualProperty; end
end
