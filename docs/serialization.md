# Serialization

## Class Options
* `exclusion_policy: CrSerializer::ExclusionPolicy` - Controls the default serialization settings of all instance variables on the class.  Defaulted to allow all.
  * See the [API docs](https://blacksmoke16.github.io/CrSerializer/CrSerializer/ExclusionPolicy.html) for enum options.

## Instance Variable Options
* `serialized_name: String` - Key to use for the given instance variable.  Defaulted to name of instance variable.
* `expose: Bool` - Whether this instance variable should be serialized or not on `#serialize`.  Defaulted to `true` (unless the class policy of `CrSerializer::ExclusionPolicy::ExcludeAll` is used).
* `emit_null: Bool` - Whether nil values should be serialized or not.  Defaulted to false.
* `accessor: {Method/instance variable}` - Defines the getter to use for this property.  Defaulted to getter of the instance variable.
* `since: String` - Specify from which version this property is available.
* `until: String` - Specify from which version this property was available.

* `groups: Array(String)` - Assign groups to create different "views".

## Accessor
```crystal
class AccessorTest
  include CrSerializer

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

## Versioned Properties

The `since` and `until` serialization options can be used to specify when a given property should start/stop being serialized.

The version to compare against is set by `CrSerializer.version = "1.2.3"`.  The version could come from anywhere: ENV variable, shard.yml, VERSION constant etc.  

**NOTE**: The version must be in SemanticVersion format.

```crystal
class VersionsTest
  include CrSerializer

  @[CrSerializer::Options(since: "1.0.0")]
  property new_name : String = "Bob"

  @[CrSerializer::Options(until: "1.0.0")]
  property old_name : String = "Bobby"

  property none : String = "None"

  @[CrSerializer::Options(until: nil)]
  property null : String = "null"
end
# Version is nil so no instance variables get serialized
VersionsTest.new.serialize # => {"none":"None","null":"null"}

CrSerializer.version = "0.5.0"
# old_name gets serialized because the app version is less the `until` version on the instance variabl
# new_name does not get serialized because the app version is less than the `since` version on the instance variable
VersionsTest.new.serialize # => {"old_name":"Bobby","none":"None","null":"null"}

CrSerializer.version = "1.0.0"
# old_name does not get serialized because the app version is now greater than the `until` version on the instance variable
# new_name gets serialized because the app version is equal to the `since` version on the instance variable
VersionsTest.new.serialize # => {"new_name":"Bob","none":"None","null":"null"}
```

## Serialization Groups

Serialization groups can be used to serialize different properties depending on which groups each property was assigned.

The `#serialize` method can take an optional array of group names that will only serialize instance variables that belong to one of the groups in the array.  Properties without a group are automatically assigned to the `default` group. 

```Crystal
class GroupTest
  include CrSerializer

  property user_id : Int32 = 999

  @[CrSerializer::Options(groups: ["admin"])]
  property admin_id : Int32 = 123

  @[CrSerializer::Options(groups: ["admin", "default"])]
  property other_id : Int32 = 7777
end

GroupTest.new.serialize                       # => {"user_id":999,"other_id":7777}
GroupTest.new.serialize(["admin"])            # => {"admin_id":123,"other_id":7777}
GroupTest.new.serialize(["admin", "default"]) # => {"user_id":999,"admin_id":123,"other_id":7777}
```

