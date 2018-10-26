module CrSerializer::Assertions
  # :nodoc:
  alias NUMERIC_DATA_TYPES = Float32 | Float64 | Int8 | Int16 | Int32 | Int64 | Int128 | UInt8 | UInt16 | UInt32 | UInt64 | UInt128

  # :nodoc:
  alias ALL_DATA_TYPES = NUMERIC_DATA_TYPES | Bool | String | Nil

  # Mapping of assertion name to fields used for it
  #
  # Used to define annotation classes and keys that should be read off of it
  ASSERTIONS = {
    CrSerializer::Assertions::NotNil             => [:noop],
    CrSerializer::Assertions::IsNil              => [:noop],
    CrSerializer::Assertions::NotBlank           => [:noop],
    CrSerializer::Assertions::IsBlank            => [:noop],
    CrSerializer::Assertions::IsTrue             => [:noop],
    CrSerializer::Assertions::IsFalse            => [:noop],
    CrSerializer::Assertions::EqualTo            => [:value],
    CrSerializer::Assertions::NotEqualTo         => [:value],
    CrSerializer::Assertions::LessThan           => [:value],
    CrSerializer::Assertions::LessThanOrEqual    => [:value],
    CrSerializer::Assertions::GreaterThan        => [:value],
    CrSerializer::Assertions::GreaterThanOrEqual => [:value],
    CrSerializer::Assertions::InRange            => [:range, :min_message, :max_message],
    CrSerializer::Assertions::Choice             => [:choices],
  }

  {% for t in ASSERTIONS %}
    # :nodoc:
    annotation {{t}}; end
  {% end %}

  # Base class of all assertions
  #
  # Sets the field ivar and message if no message was provided
  abstract class Assertion
    # The message that will be shown if the value is not valid
    getter message : String

    def initialize(@field : String, message : String?)
      @message = message ? message : "'#{@field}' has failed the #{{{@type.class.name.split("::").last.split('(').first.underscore}}}"
    end

    # Returns true if the provided value passes the assertion, otherwise false
    abstract def valid? : Bool
  end
end
