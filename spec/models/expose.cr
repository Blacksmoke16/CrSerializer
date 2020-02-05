@[CRS::ExclusionPolicy(:all)]
class Expose
  include CrSerializer

  def initialize; end

  @[CRS::Expose]
  property name : String = "Jim"

  property password : String? = "monkey"

  @[CRS::IgnoreOnSerialize]
  property ignored_serialize : Bool = false

  @[CRS::IgnoreOnDeserialize]
  property ignored_deserialize : Bool = true
end
