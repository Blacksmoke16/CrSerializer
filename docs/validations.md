# Validations

CrSerializer offers various common assertions.  Visit the [Assertions API docs](https://blacksmoke16.github.io/CrSerializer/CrSerializer/Assertions.html) for more information on each specific assertion; such as optional fields and/or limitations.

Also be sure to check out the API docs on each assertion's parent class(es) for information that can be used for all assertions inheriting from that class. `Assertion`, `BasicAssertion`, `ComparisonAssertion`, and `RangeAssertion`.

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
* `IsFalse` - Asserts that a property is false (== false).
* `IsNil` - Asserts that a property is nil
* `NotNil` - Asserts that a property is not nil
* `Size` - Asserts that the size of a property is within a given range


Custom assertions can also be defined for more use case specific cases.  See the - [Custom Assertions](./custom_assertions.md) docs for more info.