# Parent class of all parse errors.
# Can be used to rescue all parse errors regardless of format.
#
# Can also be used to raise format agnostic parse errors.
class CrSerializer::Exceptions::ParseError < Exception
end

# Raised in the event of a JSON parse error.  Such as type mistmach, missing key, etc.
class CrSerializer::Exceptions::JSONParseError < CrSerializer::Exceptions::ParseError
end
