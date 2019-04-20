# Documentation

CrSerializer has two main focuses:  serialization/deserialization and validations.

## Serialization/Deserialization

CrSerializer enables finer control of object serialization and deserialization, with support for  both YAML and JSON.  Some options are applied at the class level while others are at the instance variable level.

### Usage

Simply  `include CrSerializer(T)` into your class/struct, where `T` is the serialization format you wish to use.  Either `JSON`, `YAML`, or `JSON | YAML`.

### Without Serialization

If you wish to use validations but not include a serialization format, include `CrSerializer` with a generic type of `Nil`.  Then just be sure to call `validate` in the initializer(s) to validate the initial state of the object.

```crystal
class Example
  include CrSerialize(Nil)
    
  def initialize(@age : Int32)
    validate
  end

  @[Assert::GreaterThanOrEqual(value: 0)]
  property age : Int32
end

model = Example.new 10
model.valid? # => true

model = Example.new -100
model.valid? # => false
```

### Class Options

The class level annotation controls how all instance variables in the class behave on serialization and deserialization. 

```crystal
@[CrSerializer::ClassOptions(raise_on_invalid: false, validate: false)]
class Example
  include CrSerializer(JSON)

  property name : String = "John"
end
```

### Instance Variable options

The instance variable annotation controls how that instance variables behave on serialization and deserialization. 

```crystal
class Example
  include CrSerializer(JSON)

  @[CrSerializer::Options(expose: false, readonly: true)]
  property password : String
end
```
* [Serialization](./serialization.md) 
* [Deserialization](./deserialization.md) 

## Validations

CrSerializer enables assertions to be set on instance variables that will run on demand and on deserialization.  Multiple assertions can be defined on an instance variable.  Custom assertions can also be registered. 

By default validations will run on deserialization, unless the class annotation `validate` is set to false.  An exception can be raised if the object is invalid by setting the class annotation `raise_on_invalid` to true.  CrSerializer defines some methods related to validations when included, see the  [API docs](https://blacksmoke16.github.io/CrSerializer/CrSerializer/Validator.html) for more info.

A model can be manually validated by calling `validate` on it.  This will rerun all the assertions on the current state of the object.

**NOTE**:  Unless you define a `Assert::NotNil` assertion on an instance variable, nil values are considered valid.

```crystal
class Example
  include CrSerializer(JSON)

  # Validates on that age is >= 0 AND not nil
  @[Assert::NotNil] 
  @[Assert::GreaterThanOrEqual(value: 0)] 
  property age : Int32?
end

model = Example.from_json %({"age": 10})
model.valid? # => true
model.age = -1
model.valid? # => true
model.validate
model.valid? # => false
model.to_json # => {"age": -1}
```
- [Validations](./validations.md)
- [Custom Assertions](./custom_assertions.md)

## Example Usage

```crystal
require "CrSerializer"

# Raise an exception if a validation test fails
@[CrSerializer::ClassOptions(raise_on_invalid: true)]
class Example
  include CrSerializer(JSON)

  property name : String
  
  # Validates on deserialization that value is >= 0 AND not nil
  @[Assert::NotNil] 
  @[Assert::GreaterThanOrEqual(value: 0)] 
  property age : Int32?
  
  # Do not inclue password on serialize, nor set it on deserialize
  @[CrSerializer::Options(expose: false, readonly: true)]
  property password : String?
end

json_str = %({"name": "John", "age": 22, "password": "passw0rd!"})

example = Example.from_json json_str
example.name # => "John"
example.age # => 22

# password is nil because it was set to `readonly`
example.password # => nil

example.password = "passw0rd!"

example.password # => "passw0rd!"

# password is not serialized because `expose` was set to false
example.to_json # => {"name":"John","age":22}


json_str = %({"name": "John", "age": -1, "password": "passw0rd!"})
# raises an exepction due to `raise_on_invalid` being true
example2 = Example.from_json json_str # => Unhandled exception: Validation tests failed (CrSerializer::Exceptions::ValidationException)
```
