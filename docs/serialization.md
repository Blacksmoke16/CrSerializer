# Serialization

## Class Options
* `exclusion_policy: CrSerializer::ExclusionPolicy` - Controls the default serialization settings of all instance variables on the class.  Defaulted to allow all.
  * See the [API docs](https://blacksmoke16.github.io/CrSerializer/CrSerializer/ExclusionPolicy.html) for enum options.

## Instance Variable Options
* `serialized_name: String` - Key to use for the given instance variable.  Defaulted to name of instance variable.
* `expose: Bool` - Whether this instance variable should be serialized or not on `#serialize`.  Defaulted to `true` (unless the class policy of `CrSerializer::ExclusionPolicy::ExcludeAll` is used).
* `emit_null: Bool` - Whether nil values should be serialized or not.  Defaulted to false.
* `accessor - {Method/instance variable}` - Defines the getter to use for this property.  Defaulted to getter of the instance variable.  For example:
```crystal
class AccessorTest
  include CrSerializer::Json

  @[CrSerializer::Json::Options(accessor: get_name)]
  property name : String

  def get_name : String
    @name.upcase
  end
end

model = AccessorTest.new
model.name = "John"
model.serialize # => {"name":"JOHN"}
```