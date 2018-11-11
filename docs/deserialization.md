# Deserialization

## Class Options
* `raise_on_invalid: Bool` - Raise `CrSerializer::Exceptions::ValidationException` if the object fails any of its assertions.  Defaulted to `false`.
* `validate: Bool` - Whether the object should be validated on deserialization.  Defaulted to `true`.


## Instance Variable Options
* `readonly: Bool` - Skip this instance variable on `#deserialize` but display it on `#serialize`.  Defaulted to `false`.
