require "./context"

# Stores runtime data about the current serialization action.
class CrSerializer::SerializationContext < CrSerializer::Context
  # If `null` values should be emitted.
  #
  # ```
  # class Example
  #   include CrSerializer
  #
  #   def initialize; end
  #
  #   property name : String = "Jim"
  #   property age : Int32? = nil
  # end
  #
  # Example.new.to_json # => {"name":"Jim"}
  #
  # context = CrSerializer::SerializationContext.new
  # context.emit_nil = true
  #
  # Example.new.to_json context # => {"name":"Jim","age":null}
  # ```
  property? emit_nil : Bool = false
end
