# Includes type overrides common to all formats.
require "uuid"

private macro define_methods
  def self.deserialize(format : CrSerializer::Format.class, input : String | IO, context : CrSerializer::DeserializationContext? = nil)
    format.deserialize \{{@type}}, input, context
  end

  def serialize(format : CrSerializer::Format.class, context : CrSerializer::SerializationContext? = nil) : String
    format.serialize self, context
  end
end

# :nodoc:
class Array
  define_methods
end

# :nodoc:
struct Bool
  define_methods
end

# :nodoc:
struct Enum
  define_methods
end

# :nodoc:
class Hash
  define_methods
end

# :nodoc:
struct JSON::Any
  define_methods
end

# :nodoc:
struct NamedTuple
  define_methods
end

# :nodoc:
struct Nil
  define_methods
end

# :nodoc:
struct Number
  define_methods
end

# :nodoc:
struct Set
  define_methods
end

# :nodoc:
class String
  define_methods
end

struct Slice(T)
  define_methods
end

# :nodoc:
struct Symbol
  define_methods
end

# :nodoc:
struct Time
  define_methods
end

# :nodoc:
struct Tuple
  define_methods
end

# :nodoc:
struct UUID
  define_methods
end

# :nodoc:
struct Union
  define_methods
end

# :nodoc:
struct YAML::Any
  define_methods
end
