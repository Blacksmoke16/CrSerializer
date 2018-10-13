# CrSerializer

JSON (and later YAML) serializer and validator inspired by [JMS Serializer Annotations](https://jmsyst.com/libs/serializer/master/reference/annotations) and [Symphony Validation Constraint Annotations](https://symfony.com/doc/current/reference/constraints.html).  Built on top of the standard library functionality of `JSON::Serializable`.

## Goals

- Be a compliment to, not a replacement for, `JSON::Serializable`
- Extensible and customizable to fit all use cases
- Make working with JSON APIs in Crystal much easier
- Be easy to adopt and start using effectively
- Work out of the box with most ORMs (assuming they are compatible with `JSON::Serializable`)

## Roadmap

- [x] JSON Support
- [ ] YAML Support

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  CrSerializer:
    github: Blacksmoke16/CrSerializer
```

## Usage

```crystal
require "CrSerializer"

# Raise an exception if a validation test fails
@[CrSerializer::Options(raise_on_invalid: true)]
class Example
  include CrSerializer::Json

  property name : String
  
  # Validates on deserialization that value is >= 0 AND not nil
  @[CrSerializer::Assertions(greater_than_or_equal: 0, nil: false)] 
  property age : Int32
  
  # Do not inclue password on serialize, nor set it on deserialize
  @[CrSerializer::Json::Options(expose: false, readonly: true)]
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
example2 = Example.deserialize json_str # => Unhandled exception: Validation tests failed (CrSerializer::ValidationException)
```

#### Instance Variables properties

- [x] `expose: Bool`- Whether the property should be serialized.  Default = `true`

- [x] `emit_null: Bool` - Whether variables with nil values should be serialized. Default = `false`

- [x] `accessor: {{getter_method_name}}` - Use a custom getter method instead of `@{{variable_name}}`

- [x] `readonly: Bool` - Whether the property should be settable on deserialization.  Default = `true`

- [x] `serialized_name: String` - Name of the key to use on serialize.  Default = name of instance variable

#### Class properties

- [x] `validate: Bool`: Whether validations should be ran for this class.  Default = `true`
- [x] `raise_on_invalid: Bool`: Whether an exception should be raised if a validation test fails.  Default = `false`

### Validations

#### Generic

- [x] `nil: Bool` - Whether the property should be allowed to be nil
- [x] `equal: V` - Value is equal to `V`.  Use `nil: true` instead of `equal: nil`
- [x] `not_equal: V`- Values is not equal to `V`. Use `nil: false` instead of `not_equal: nil`
- [x] `choice: Array(String|Number)` - Value is of a given set of choices

#### Numeric

- [x] `greater_than: N` - Value of the property should be greater than `N`
- [x] `greater_than_or_equal: N` - Value of the property should be greater than or equal `N`
- [x] `less_than: N` - Value of the property should be less than `N`
- [x] `less_than_or_equal: N` - Value of the property should be less than or equal to `N`
- [x] `range: Range(B, E)` - Value is within `B` and `E`

#### String

- [x] `blank: Bool` - Whether the property should be allowed to be blank
- [x] `size: Range(B, E)` - Size of the string is between `B` and `E`
- [x] `regex: Regex` - Value matches `Regex` pattern
- [ ] `email: String` - Value is an property formatted email

#### Array

- [x] `size: Range(B, E)` - Size of the array is between `B` and `E`
- [x] `unique: Bool` - Whether all values should be unique

#### Date

- [ ] `format: String` - Value is is a date in the given format

## Contributing

1. Fork it (<https://github.com/Blacksmoke16/CrSerializer/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Blacksmoke16](https://github.com/Blacksmoke16) Blacksmoke16 - creator, maintainer
