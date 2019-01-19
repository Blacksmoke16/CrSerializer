module CrSerializer::Assertions
  # :nodoc:
  alias NUMERICDATATYPES = Float32 | Float64 | Int8 | Int16 | Int32 | Int64 | Int128 | UInt8 | UInt16 | UInt32 | UInt64 | UInt128

  # :nodoc:
  alias ALLDATATYPES = NUMERICDATATYPES | Bool | String | Nil

  # Mapping of assertion name to fields used for it
  #
  # Used to define annotation classes and keys that should be read off of it
  ASSERTIONS = {
    Assert::NotNil             => ([] of Symbol),
    Assert::IsNil              => ([] of Symbol),
    Assert::NotBlank           => ([] of Symbol),
    Assert::IsBlank            => ([] of Symbol),
    Assert::IsTrue             => ([] of Symbol),
    Assert::IsFalse            => ([] of Symbol),
    Assert::Valid              => ([] of Symbol),
    Assert::Luhn               => ([] of Symbol),
    Assert::EqualTo            => [:value],
    Assert::NotEqualTo         => [:value],
    Assert::LessThan           => [:value],
    Assert::LessThanOrEqual    => [:value],
    Assert::GreaterThan        => [:value],
    Assert::GreaterThanOrEqual => [:value],
    Assert::Email              => [:mode],
    Assert::IP                 => [:version],
    Assert::Uuid               => [:versions, :variants, :strict],
    Assert::Url                => [:protocols, :relative_protocol],
    Assert::RegexMatch         => [:pattern, :match],
    Assert::InRange            => [:range, :min_message, :max_message],
    Assert::Size               => [:range, :min_message, :max_message],
    Assert::Choice             => [:choices, :min_matches, :max_matches, :min_message, :max_message, :multiple_message],
  }

  # Base class of all assertions
  #
  # Sets the field instance variable name, and message if no message was provided
  abstract class Assertion
    # :nodoc:
    getter message : String = "The #{{{@type.name.split("::").last.split('(').first}}} has failed."

    # The property that the assertion is tested against
    getter field : String

    def initialize(@field : String, message : String?)
      if msg = message
        @message = msg
      end
    end

    # Returns true if the provided property passes the assertion, otherwise false.
    #
    # TODO make this abstract once [this issue](https://github.com/crystal-lang/crystal/issues/6996) is resolved.
    def valid? : Bool
      true
    end

    # Message to display when validation fails.
    #
    # TODO make this abstract once [this issue](https://github.com/crystal-lang/crystal/issues/6996) is resolved.
    def error_message : String
      ""
    end

    macro inherited

      # The current value of the property
      getter actual

      # The message that will be shown if the assertion is not valid
      def error_message : String
        {% for k, v in CrSerializer::Assertions::ASSERTIONS %}
          {% if @type.class.name.includes? k.stringify.split("::").last %}
            {% v = v.expressions[0] if v.is_a?(Expressions) %}
            {% for field in v %}
              @message = @message.sub("\{{{{field.id}}}}", @{{field.id}})
            {% end %}
          {% end %}
        {% end %}
        @message = @message.sub("\{{field}}", @field)
        act = @actual.to_s
        act = "null" if act.nil?
        act = %("") if act == ""
        @message = @message.sub("\{{actual}}", act)
        @message
      end
    end
  end
end
