# Custom Assertions

If none of the built in assertions would work for a given use case, custom assertions can be defined and used.

1. Use the `register_assertion` macro to define the name of the annotation and fields that can be read off of it.

**NOTE**: a `message` field is included by default on each assertion that can be used to override the message when an assertion fails.

```crystal
register_assertion CrSerializer::Assertions::MyCustom, [:value, :high_is_good]
```

This would allow the annotation to be used like:

```crystal
@[CrSerializer::Assertions::MyCustom(value: 100, high_is_good: true)]
property age : Int32
```

2. Define an assertion class, in the `CrSerializer::Assertions` namespace with generics, that inherits from the `CrSerializer::Assertions::Assertion` class.  The assertion class must be the annotation name + `Assertion`. 
```crystal
module CrSerializer::Assertions
  class MyCustomAssertion(ActualValueType) < CrSerialize::Assertions::Assertion
  end
end
```

The assertion class must define an initialize method.

```crystal
    def initialize(
      field : String, # => Name of the instance variable
      message : String?, # => Message to display if the assertion fails
      @actual : ActualValueType, # => value of the instance variable
      @value : CrSerializer::Assertions::ALLDATATYPES, # => Value of the `value` annotation field
      @high_is_good : Bool, # => Value of the `high_is_good` annotation field
    )
      super field, message # => Calls the parent's initializer to set field name and message
    end
```

This defines that the type of `high_is_good` must be a `Bool`, while `value` can be anything.  This offers type safety so that you cannot have, for example, a `NotBlank` assertion on an `Int32` property.

The assertion class must also implement a `valid?` method that returns a boolean on whether it has passed the assertion or not.

```crystal
def valid? : Bool
  hig : Bool = @high_is_good
  act : ActualValueType = @actual
  hig ? act > 0 : act < 0
end
```

3. Start using the new custom assertion!

## Predefined Interfaces

In some cases, the fields that will be read off an annotation will be the same as a current assertion, just with different `valid?` logic.  In this case, the custom assertion call can inherit from a predefined abstract class that handles the `initialization` of the class, so only the `valid?` method has to be defined. 

```crystal
register_assertion CrSerializer::Assertions::Foo, [] of Symbol

module CrSerializer::Assertions
  class FooAssertion(ActualValueType) < BasicAssertion(CrSerializer::Assertions::ALLDATATYPES)
    def valid?
      @actual == "foo"
    end
  end
end
```

In this case, since we are not using any annotation fields, we can inherit from the `BasicAssertion` class, still giving it the allowed type.  There are a few other predefined interfaces that can be used; check out the [API Docs](https://blacksmoke16.github.io/CrSerializer/CrSerializer/Assertions.html) for more information on them.

* `BasicAssertion` - Used with no annotation fields
* `ComparisionAssertion` - Used with a single `value` annotation field
* `RangeAssertion` - Used with `range, min_message, and max_message` annotation fields

