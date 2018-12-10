require "./CrSerializer/**"

module CrSerializer
  # Version used as the comparator for the `since` and `until` serialization options.
  #
  # Should be set in your app's main file, such as;
  # ```
  # CrSerializer.version = MyApp::VERSION
  # ```
  #
  # NOTE: Must be a `SemanticVersion` string
  class_property version : String?

  # :nodoc:
  annotation ClassOptions; end

  # :nodoc:
  annotation Options; end

  # Controls the default serialization settings of all instance variables on the class.
  enum ExclusionPolicy
    # Do not serialize any instance variables unless `expose: true` is explicitly set on an instance variable
    EXCLUDE_ALL
  end
end
