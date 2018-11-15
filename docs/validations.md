# Validations

CrSerializer offers various common assertions.  Visit the [Assertions API docs](https://blacksmoke16.github.io/CrSerializer/CrSerializer/Assertions.html) for more information on each specific assertion; such as optional fields and/or limitations.

* `Choice` - Asserts that a property is a valid choice
* `EqualTo` - Asserts that a property is equal to a value
* `NotEqualTo` - Asserts that a property is not equal to a value
* `GreaterThan` - Asserts that a property is greater than a value
* `GreaterThanOrEqual` - Asserts that a property is grater than or equal to a value
* `LessThan` - Asserts that a property is less than a value
* `LessThanOrEqual` - Asserts that a property is less than or equal to a value
* `InRange` - Asserts that a property is within a given range
* `IsBlank` - Asserts that a property is blank (empty string)
* `NotBlank` - Asserts that a property is not blank
* `IsTrue` - Asserts that a property is true (== true)
* `IsFalse` - Asserts that a property is false (== false)
* `IsNil` - Asserts that a property is nil
* `NotNil` - Asserts that a property is not nil
* `Size` - Asserts that the size of a property is within a given range
* `RegexMatch` - Asserts that the property matches the given Regex pattern
* `Valid` - Asserts that the child object(s) must be valid for the property to be valid
* `Url` - Asserts that the property is a valid URL
* `Email` - Asserts that the property is a valid email address
* `IP` - Asserts that the property is a valid IP address
* `Uuid` - Asserts that the property if a valid RFC4122 UUID

Custom assertions can also be defined for more use case specific cases.  See the - [Custom Assertions](./custom_assertions.md) docs for more info.

## Error Messages

Each assertion has an auto defined `message` field that can be used to override the default error message.  

```
@[Assert::EqualTo(value: "Jim", message: "name is not equal")]
property name : String
```

### Placeholders

Placeholders can be defined in the error message that will render their corresponding value after validation.

```crystal
@[Assert::EqualTo(value: "Jim", message: "Expected {{field}} to equal {{value}} but got {{actual}}")]
property name : String

# Assuming the property is invalid, it would return the message
"Expected name to equal Jim but got foo"

```

#### Placeholder Patterns

The following two patterns are available on every assertion:

* `{{field}}` - The name of the property the assertion is on

* `{{actual}}` - The property's current value

Placeholder patterns are also available for each assertion specific field.  For example, the `EqualTo` assertion above allows you to use `{{value}}`, which represents the value that the property should equal.