# :nodoc:
module YAML::Nodes
  class Document < Node
    def to_yaml(builder : YAML::Builder, serialization_groups : Array(String), expand : Array(String))
      nodes.each &.to_yaml builder, serialization_groups, expand
    end
  end

  class Mapping < Node
    def to_yaml(builder : YAML::Builder, serialization_groups : Array(String), expand : Array(String))
      builder.mapping(anchor, tag, style) do
        each do |key, value|
          key.to_yaml builder, serialization_groups, expand
          value.to_yaml builder, serialization_groups, expand
        end
      end
    end
  end

  class Scalar < Node
    def to_yaml(builder : YAML::Builder, serialization_groups : Array(String), expand : Array(String))
      builder.scalar(value, anchor, tag, style)
    end
  end

  class Sequence < Node
    def to_yaml(builder : YAML::Builder, serialization_groups : Array(String), expand : Array(String))
      builder.sequence(anchor, tag, style) do
        each &.to_yaml builder, serialization_groups, expand
      end
    end
  end

  class Alias < Node
    def to_yaml(builder : YAML::Builder, serialization_groups : Array(String), expand : Array(String))
      builder.alias(anchor.not_nil!)
    end
  end
end

class Object
  # Serialize `self` to YAML.
  #
  # Optionally, only serialize properties that are in *serialization_groups*.  See [the docs](https://github.com/Blacksmoke16/CrSerializer/blob/master/docs/serialization.md#serialization-groups) for more information.
  #
  # Optionally, include expandable properties that are in *expand*.  See [the docs](https://github.com/Blacksmoke16/CrSerializer/blob/master/docs/serialization.md#expansion) for more information.
  def to_yaml(serialization_groups : Array(String) = ["default"], expand : Array(String) = [] of String) : String
    String.build do |str|
      to_yaml str, serialization_groups, expand
    end
  end

  # :nodoc:
  def to_yaml(io : IO, serialization_groups : Array(String), expand : Array(String))
    nodes_builder = YAML::Nodes::Builder.new
    to_yaml nodes_builder, serialization_groups, expand
    YAML.build(io) do |builder|
      nodes_builder.document.to_yaml builder, serialization_groups, expand
    end
  end
end

# :nodoc:
class Hash
  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    yaml.mapping(reference: self) do
      each do |key, value|
        key.to_yaml yaml, serialization_groups, expand
        value.to_yaml yaml, serialization_groups, expand
      end
    end
  end
end

# :nodoc:
class Array
  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    yaml.sequence(reference: self) do
      each &.to_yaml yaml, serialization_groups, expand
    end
  end
end

# :nodoc:
struct Tuple
  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    yaml.sequence do
      each &.to_yaml yaml, serialization_groups, expand
    end
  end
end

# :nodoc:
struct NamedTuple
  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    yaml.mapping do
      {% for key in T.keys %}
        {{key.symbolize}}.to_yaml yaml, serialization_groups, expand
        self[{{key.symbolize}}].to_yaml yaml, serialization_groups, expand
      {% end %}
    end
  end
end

# :nodoc:
class String
  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    if YAML::Schema::Core.reserved_string?(self)
      yaml.scalar self, style: YAML::ScalarStyle::DOUBLE_QUOTED
    else
      yaml.scalar self
    end
  end
end

# :nodoc:
struct Number
  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    yaml.scalar self.to_s
  end
end

# :nodoc:
struct Nil
  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    yaml.scalar ""
  end
end

# :nodoc:
struct Bool
  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    yaml.scalar self
  end
end

# :nodoc:
struct Set
  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    yaml.sequence do
      each &.to_yaml yaml, serialization_groups, expand
    end
  end
end

# :nodoc:
struct Symbol
  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    yaml.scalar self
  end
end

# :nodoc:
struct Enum
  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    yaml.scalar value
  end
end

# :nodoc:
struct Time
  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    yaml.scalar Time::Format::YAML_DATE.format(self)
  end
end
