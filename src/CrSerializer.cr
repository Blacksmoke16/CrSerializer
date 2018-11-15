require "./CrSerializer/**"

module CrSerializer
  # :nodoc:
  annotation Options; end

  # Controls the default serialization settings of all instance variables on the class.
  enum ExclusionPolicy
    # Do not serialize any instance variables unless `expose: true` is explicitly set on an instance variable
    EXCLUDE_ALL
  end
end
