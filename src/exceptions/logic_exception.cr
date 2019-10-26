# Raised when `CrSerializer` is used incorrectly.  For example
# trying to re-use a `CrSerializer::SerializationContext` object.
class CrSerializer::Exceptions::LogicError < Exception
end
