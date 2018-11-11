# CrSerializer

JSON (and later YAML) serializer and validator inspired by [JMS Serializer Annotations](https://jmsyst.com/libs/serializer/master/reference/annotations) and [Symfony Validation Constraint Annotations](https://symfony.com/doc/current/reference/constraints.html).

## Goals

- Be a compliment to, not a replacement for, `JSON::Serializable` or `YAML::Serializable`
- Extensible and customizable to fit all use cases
- Make working with JSON APIs in Crystal much easier
- Be easy to adopt and start using effectively
- Work out of the box with most ORMs (assuming they are compatible with `JSON::Serializable`/annotations)

## Documentation

[Documentation](docs/readme.md)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  CrSerializer:
    github: Blacksmoke16/CrSerializer
```

## Contributing

1. Fork it (<https://github.com/Blacksmoke16/CrSerializer/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Blacksmoke16](https://github.com/Blacksmoke16) Blacksmoke16 - creator, maintainer
