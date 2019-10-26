# Defines the default exclusion strategy for all properties within a class/struct.
#
# See `CRS::ExclusionPolicy`.
enum CrSerializer::ExclusionPolicy
  # Excludes all properties by default.  Only properties annotated with `CRS::Expose` will be serialized/deserialized.
  All

  # Excludes no properties by default.  All properties except those annotated with `CRS::Exclude` will be serialized/deserialized.
  None
end
