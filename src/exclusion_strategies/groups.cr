require "./exclusion_strategy"

# Allows creating different views of your objects by limiting which properties get serialized, based on the group(s) each property is a part of.
#
# It is enabled by default when using `CrSerializer::Context#groups=`.
#
# ```
# class Example
#   include CrSerializer
#
#   def initialize; end
#
#   @[CRS::Groups("list", "details")]
#   property id : Int64 = 1
#
#   @[CRS::Groups("list", "details")]
#   property title : String = "TITLE"
#
#   @[CRS::Groups("list")]
#   property comment_summaries : Array(String) = ["Sentence 1.", "Sentence 2."]
#
#   @[CRS::Groups("details")]
#   property comments : Array(String) = ["Sentence 1.  Another sentence.", "Sentence 2.  Some other stuff."]
#
#   property created_at : Time = Time.utc(2019, 1, 1)
#   property updated_at : Time?
# end
#
# example = Example.new
#
# example.to_json(CrSerializer::SerializationContext.new.groups = ["list"])            # => {"id":1,"title":"TITLE","comment_summaries":["Sentence 1.","Sentence 2."]}
# example.to_json(CrSerializer::SerializationContext.new.groups = ["details"])         # => {"id":1,"title":"TITLE","comments":["Sentence 1.  Another sentence.","Sentence 2.  Some other stuff."]}
# example.to_json(CrSerializer::SerializationContext.new.groups = ["list", "default"]) # => {"id":1,"title":"TITLE","comment_summaries":["Sentence 1.","Sentence 2."],"created_at":"2019-01-01T00:00:00Z"}
# ```
struct CrSerializer::ExclusionStrategies::Groups < CrSerializer::ExclusionStrategies::ExclusionStrategy
  @groups : Array(String)

  def initialize(@groups : Array(String)); end

  def self.new(*groups : String)
    new groups.to_a
  end

  # :inherit:
  def skip_property?(metadata : PropertyMetadata, context : Context) : Bool
    (metadata.groups & @groups).empty?
  end
end
