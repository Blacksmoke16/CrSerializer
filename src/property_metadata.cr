module CrSerializer
  # :nodoc:
  module Metadata; end

  # Represents metadata associated with a property.
  #
  # All properties are defined via annotations applied to the property,
  # or pulled directly from the ivar declaration.
  struct PropertyMetadata(IvarType, ClassType)
    include Metadata

    # The name of the property.
    getter name : String

    # The name that should be used for serialization/deserialization.
    getter external_name : String

    # The value of the property.
    getter value : IvarType

    # The type of the property.
    getter type : IvarType.class = IvarType

    # The class that the property is part of.
    getter class : ClassType.class = ClassType

    # Represents the first version this property is available.
    #
    # See `CrSerializer::ExclusionStrategies::Version`.
    property since_version : SemanticVersion?

    # Represents the last version this property was available.
    #
    # See `CrSerializer::ExclusionStrategies::Version`.
    property until_version : SemanticVersion?

    # The serialization groups this property belongs to.
    #
    # See `CrSerializer::ExclusionStrategies::Groups`.
    getter groups : Array(String) = ["default"]

    # Deserialize this property from the property's name or any name in *aliases*.
    #
    # See `CRS::Name`.
    getter aliases : Array(String)

    # If this property should not be serialized if it is empty.
    #
    # See `CRS::SkipWhenEmpty`.
    getter? skip_when_empty : Bool

    def initialize(
      @name : String,
      @external_name : String,
      @value : IvarType = nil,
      @skip_when_empty : Bool = false,
      @groups : Array(String) = ["default"],
      @aliases : Array(String) = [] of String,
      @since_version : SemanticVersion? = nil,
      @until_version : SemanticVersion? = nil,
      @type : IvarType.class = IvarType,
      @class : ClassType.class = ClassType
    )
    end
  end
end
