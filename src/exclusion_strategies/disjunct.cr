require "./exclusion_strategy"

# Wraps an `Array(CrSerializer::ExclusionStrategies::ExclusionStrategy)`, excluding a property if any member skips it.
#
# Used internally to allow multiple exclusion strategies to be used within a single instance variable for `CrSerializer::Context#add_exclusion_strategy`.
struct CrSerializer::ExclusionStrategies::Disjunct < CrSerializer::ExclusionStrategies::ExclusionStrategy
  # The wrapped exclusion strategies.
  getter members : Array(ExclusionStrategy)

  def initialize(@members : Array(ExclusionStrategy)); end

  # :inherit:
  def skip_property?(metadata : PropertyMetadata, context : Context) : Bool
    @members.any?(&.skip_property?(metadata, context))
  end
end
