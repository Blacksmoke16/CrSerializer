# Documentation

CrSerializer had two main focuses:  serialization/deserialization and validations.

## Serialization/Deserialization

CrSerializer enables finer control of object serialization and deserialization.  Some options are applied at the class level while others are at the instance variable level.

### Class Options

The class level annotation controls how all instance variables in the class behave on serialization and deserialization. 

```crystal
@[CrSerializer::ClassOptions(raise_on_invalid: false, validate: false)]
class Example
  property name : String = "John"
end
```

### Instance Variable options

The instance variable annotation controls how that instance variables behave on serialization and deserialization. 

```crystal
class Example
  @[CrSerializer::Options(expose: false, readonly: true)]
  property password : String
end
```
* [Serialization](./serialization.md) 
* [Deserialization](./deserialization.md) 

## Validations

CrSerializer enables assertions to be set on instance variables that will run on demand and on deserialization.  Multiple assertions can be defined on an instance variable.  Custom assertions can also be registered. 

By default validations will run on deserialization, unless the class annotation `validate` is set to false.  An exception can be raised if the object is invalid by setting the class annotation `raise_on_invalid` to true.   

CrSerializer defines an instance variable `validator` when including the module.  See the  [API docs](https://blacksmoke16.github.io/CrSerializer/CrSerializer/Validator.html) for more info.

A model can be manually validated by calling `validate` on it.  This will rerun all the assertions on the current state of the object.

**NOTE**:  Unless you define a `Assert::NotNil` assertion on an instance variable, nil values are considered valid.

```crystal
class Example
  # Validates on that age is >= 0 AND not nil
  @[Assert::NotNil] 
  @[Assert::GreaterThanOrEqual(value: 0)] 
  property age : Int32?
end

model = Example.deserialize %({"age": 10})
model.validator.valid? # => true
model.age = -1
model.validator.valid? # => true
model.validate
model.validator.valid? # => false
model.serialize # => {"age": -1}
```
- [Validations](./validations.md)
- [Custom Assertions](./custom_assertions.md)

## Example Usage

```crystal
require "CrSerializer"

# Raise an exception if a validation test fails
@[CrSerializer::ClassOptions(raise_on_invalid: true)]
class Example
  include CrSerializer

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

example = Example.deserialize json_str
example.name # => "John"
example.age # => 22

# password is nil because it was set to `readonly`
example.password # => nil

example.password = "passw0rd!"

example.password # => "passw0rd!"

# password is not serialized because `expose` was set to false
example.serialize # => {"name":"John","age":22}


json_str = %({"name": "John", "age": -1, "password": "passw0rd!"})
# raises an exepction due to `raise_on_invalid` being true
example2 = Example.deserialize json_str # => Unhandled exception: Validation tests failed (CrSerializer::Exceptions::ValidationException)
```