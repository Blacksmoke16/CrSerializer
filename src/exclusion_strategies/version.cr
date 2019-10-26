require "./exclusion_strategy"

# Serialize properties based on a `SemanticVersion` string.
#
# It is enabled by default when using `CrSerializer::Context#version=`.
#
# ```
# class Example
#   include CrSerializer
#
#   def initialize; end
#
#   @[CRS::Until("1.0.0")]
#   property name : String = "Legacy Name"
#
#   @[CRS::Since("1.1.0")]
#   property name2 : String = "New Name"
# end
#
# example = Example.new
#
# example.to_json(CrSerializer::SerializationContext.new.version = "0.30.0") # => {"name":"Legacy Name"}
# example.to_json(CrSerializer::SerializationContext.new.version = "1.2.0")  # => {"name2":"New Name"}
# ```
struct CrSerializer::ExclusionStrategies::Version < CrSerializer::ExclusionStrategies::ExclusionStrategy
  getter version : SemanticVersion

  def initialize(@version : SemanticVersion); end

  # :inherit:
  def skip_property?(metadata : PropertyMetadata, context : Context) : Bool
    # Skip if *version* is not at least *since_version*.
    return true if (since_version = metadata.since_version) && @version < since_version

    # Skip if *version* is greater than or equal to than *until_version*.
    return true if (until_version = metadata.until_version) && @version >= until_version

    false
  end
end
