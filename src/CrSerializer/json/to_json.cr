class Object
  # Serialize `self` to JSON.
  #
  # Optionally, only serialize properties that are in *serialization_groups*.  See [the docs](https://github.com/Blacksmoke16/CrSerializer/blob/master/docs/serialization.md#serialization-groups) for more information.
  #
  # Optionally, include expandable properties that are in *expand*.  See [the docs](https://github.com/Blacksmoke16/CrSerializer/blob/master/docs/serialization.md#expansion) for more information.
  def to_json(serialization_groups : Array(String) = ["default"], expand : Array(String) = [] of String) : String
    String.build do |str|
      to_json str, serialization_groups, expand
    end
  end

  def to_json(io : IO, serialization_groups : Array(String), expand : Array(String))
    JSON.build(io) do |json|
      to_json json, serialization_groups, expand
    end
  end

  def to_pretty_json(indent : String = "  ", serialization_groups : Array(String) = ["default"], expand : Array(String) = [] of String)
    String.build do |str|
      to_pretty_json str, serialization_groups, expand, indent: indent
    end
  end

  def to_pretty_json(io : IO, serialization_groups : Array(String), expand : Array(String), indent : String = "  ")
    JSON.build(io, indent: indent) do |json|
      to_json json, serialization_groups, expand
    end
  end
end

# :nodoc:
struct Nil
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.null
  end
end

# :nodoc:
struct Bool
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.bool(self)
  end
end

# :nodoc:
struct Int
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.number(self)
  end
end

# :nodoc:
struct Float
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.number(self)
  end
end

# :nodoc:
class String
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.string(self)
  end
end

# :nodoc:
struct Symbol
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.string(to_s)
  end
end

# :nodoc:
class Array
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.array do
      each &.to_json json, serialization_groups, expand
    end
  end
end

# :nodoc:
struct JSON::Any
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    raw.to_json json, serialization_groups, expand
  end

  def to_yaml(yaml : YAML::Nodes::Builder, serialization_groups : Array(String), expand : Array(String))
    raw.to_yaml yaml, serialization_groups, expand
  end
end

# :nodoc:
struct Set
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.array do
      each &.to_json json, serialization_groups, expand
    end
  end
end

# :nodoc:
class Hash
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.object do
      each do |key, value|
        json.field key do
          value.to_json json, serialization_groups, expand
        end
      end
    end
  end
end

# :nodoc:
struct Tuple
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.array do
      {% for i in 0...T.size %}
        self[{{i}}].to_json json, serialization_groups, expand
      {% end %}
    end
  end
end

# :nodoc:
struct NamedTuple
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.object do
      {% for key in T.keys %}
        json.field {{key.stringify}} do
          self[{{key.symbolize}}].to_json json, serialization_groups, expand
        end
      {% end %}
    end
  end
end

# :nodoc:
struct Enum
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.number(value)
  end
end

# :nodoc:
struct Time
  def to_json(json : JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    json.string(Time::Format::RFC_3339.format(self, fraction_digits: 0))
  end
end
