require "../CrSerializer"

# Exclusion strategies are used to determine which properties within a class/struct should be serialized and deserialized.
# This module includes all of the built in exclusion strategies.
#
# See `CrSerializer::ExclusionStrategies::ExclusionStrategy` for high level exclusion strategy documentation, as well each each specific strategy for more details.
module CrSerializer::ExclusionStrategies
  # Base struct of all exclusion strategies.
  #
  # Custom exclusion strategies can be defined by simply inheriting from the base struct and implementing the `#skip_property?` method.
  abstract struct ExclusionStrategy
    # Returns `true` if a property should _NOT_ be serialized/deserialized.
    abstract def skip_property?(metadata : PropertyMetadata, context : Context) : Bool

    def initialize; end
  end
end
