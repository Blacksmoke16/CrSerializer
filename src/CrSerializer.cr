require "./CrSerializer/**"

module CrSerializer(T)
  # Version used as the comparator for the `since` and `until` serialization options.
  #
  # Should be set in your app's main file, such as:
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

  # :nodoc:
  annotation Expandable; end

  # Controls the default serialization settings of all instance variables on the class.
  enum ExclusionPolicy
    # Do not serialize any instance variables unless `expose: true` is explicitly set on an instance variable
    ExcludeAll
  end
end

class Klass
  include CrSerializer(Nil)

  def initialize(@age : Int32?)
    validate
  end

  @[Assert::NotNil]
  @[Assert::GreaterThanOrEqual(value: 0)]
  property age : Int32?
end

model = Klass.new 10
model.valid? # => true

model = Klass.new -100
model.valid? # => false
