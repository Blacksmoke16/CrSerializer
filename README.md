# CrSerializer

JSON (and later YAML) serializer and validator inspired by [JMS Serializer Annotations](https://jmsyst.com/libs/serializer/master/reference/annotations) and [Symfony Validation Constraint Annotations](https://symfony.com/doc/current/reference/constraints.html).

## Goals

- Be a compliment to, not a replacement for, `JSON::Serializable` or `YAML::Serializable`
- Extensible and customizable to fit all use cases
- Make working with JSON APIs in Crystal much easier
- Be easy to adopt and start using effectively
- Work out of the box with most ORMs (assuming they are compatible with `JSON::Serializable`/annotations)

## Roadmap

- [x] JSON Support
  - [x] Basic Constraints
  - [x] Comparison Constraints
  - [ ] String Constraints
  - [ ] Date Constraints
  - [ ] Collection Constraints
  - [ ] Financial/Other Constraints
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
  @[CrSerializer::Assertions::NotNil] 
  @[CrSerializer::Assertions::GreaterThanOrEqual(value: 0)] 
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
example2 = Example.deserialize json_str # => Unhandled exception: Validation tests failed (CrSerializer::Exceptions::ValidationException)
```

## Contributing

1. Fork it (<https://github.com/Blacksmoke16/CrSerializer/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Blacksmoke16](https://github.com/Blacksmoke16) Blacksmoke16 - creator, maintainer
