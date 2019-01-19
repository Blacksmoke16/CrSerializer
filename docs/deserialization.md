# Deserialization

## Class Options
* `raise_on_invalid: Bool` - Raise `CrSerializer::Exceptions::ValidationException` if the object fails any of its assertions.  Defaulted to `false`.
* `validate: Bool` - Whether the object should be validated on deserialization.  Defaulted to `true`.

## Instance Variable Options
* `readonly: Bool` - Skip this instance variable on `.from_*` but display it on `#to_*`.  Defaulted to `false`.

## PostDeserialize Callback

A method can be defined that will run **after** the object has been deserialized.   This can be useful for setting calculated properties based on the data from the input string.

```crystal
class Klass
  include CrSerializer

  property name : String

  def after_initialize
    super
    @name = @name.upcase
  end
end

Klass.from_json %({"name": "bob"}) # => #<Klass:0x7f4b478aeec0 @name="BOB", ...>
```

**NOTE**:  You **_must_** call `super` in the `after_initialize` method, otherwise validations will not run.