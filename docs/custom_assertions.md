# Custom Assertions

If none of the built in assertions would work for a given use case, custom assertions can be defined and used.

1. Use the `register_assertion` macro to define the name of the annotation and fields that can be read off of it.

```crystal
register_assertion Assert::MyCustom, [:value, :high_is_good]
```

This would allow the annotation to be used like:

```crystal
@[Assert::MyCustom(value: 100, high_is_good: true)]
property age : Int32
```

2. Define an assertion class, with generics, that inherits from the `CrSerializer::Assertions::Assertion` class.  The assertion class must be the annotation name + `Assertion`. 

A custom failed assertion message can be defined by adding an `@message : String` instance variable in the class.  The same placeholder values are also usable in custom assertions.
```crystal

class MyCustomAssertion(ActualValueType) < CrSerialize::Assertions::Assertion
  @message : String = "'{{field}}' does not equal foo"
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

The assertion class must also implement a `valid?` method that returns a `Bool` on whether the property has passed the assertion.

```crystal
def valid? : Bool
  hig : Bool = @high_is_good
  act : ActualValueType = @actual
  hig ? act > 0 : act < 0
end
```

3. Start using the new custom assertion!

The final class would be:
```crystal
class MyCustomAssertion(ActualValueType) < CrSerialize::Assertions::Assertion
  @message : String = "'{{field}}' does not equal foo"

  def initialize(
    field : String, # => Name of the instance variable
    message : String?, # => Message to display if the assertion fails
    @actual : ActualValueType, # => value of the instance variable
    @value : CrSerializer::Assertions::ALLDATATYPES, # => Value of the `value` annotation field
    @high_is_good : Bool, # => Value of the `high_is_good` annotation field
  )
    super field, message # => Calls the parent's initializer to set field name and message
  end
  
  def valid? : Bool
    hig : Bool = @high_is_good
    act : ActualValueType = @actual
    hig ? act > 0 : act < 0
  end
end
```
