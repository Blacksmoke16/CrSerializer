require "semantic_version"

# Stores runtime data about the current action.
#
# Such as what serialization groups/version to use when serializing.
#
# NOTE: Cannot be used for more than one action.
abstract class CrSerializer::Context
  # The `CrSerializer::ExclusionStrategies::ExclusionStrategy` being used.
  getter exclusion_strategy : CrSerializer::ExclusionStrategies::ExclusionStrategy?

  @initalizer : Bool = false

  # Returns the serialization groups, if any, currently set on `self`.
  getter groups : Array(String)? = nil

  # Returns the version, if any, currently set on `self`.
  getter version : SemanticVersion? = nil

  # Adds *strategy* to `self`.
  #
  # * `exclusion_strategy` is set to *strategy* if there previously was no strategy.
  # * `exclusion_strategy` is set to `CrSerializer::ExclusionStrategies::Disjunct` if there was a `exclusion_strategy` already set.
  # * *strategy* is added to the `CrSerializer::ExclusionStrategies::Disjunct` if there are multiple strategies.
  def add_exclusion_strategy(strategy : CrSerializer::ExclusionStrategies::ExclusionStrategy) : self
    current_strategy = @exclusion_strategy
    case current_strategy
    when Nil                                         then @exclusion_strategy = strategy
    when CrSerializer::ExclusionStrategies::Disjunct then current_strategy.members << strategy
    else
      @exclusion_strategy = CrSerializer::ExclusionStrategies::Disjunct.new [current_strategy, strategy]
    end

    self
  end

  # :nodoc:
  def init : Nil
    raise CrSerializer::Exceptions::LogicError.new "This context was already initialized, and cannot be re-used." if @initialized

    if v = @version
      add_exclusion_strategy CrSerializer::ExclusionStrategies::Version.new v
    end

    if g = @groups
      add_exclusion_strategy CrSerializer::ExclusionStrategies::Groups.new g
    end

    @initialized = true
  end

  # Sets the group(s) to compare against properties' `CRS::Groups` annotations.
  #
  # Adds a `CrSerializer::ExclusionStrategies::Groups` automatically if set.
  def groups=(groups : Array(String)) : self
    raise ArgumentError.new "Groups cannot be empty" if groups.empty?

    @groups = groups

    self
  end

  # Sets the version to compare against properties' `CRS::Since` and `CRS::Until` annotations.
  #
  # Adds a `CrSerializer::ExclusionStrategies::Version` automatically if set.
  def version=(version : String) : self
    @version = SemanticVersion.parse version

    self
  end
end
