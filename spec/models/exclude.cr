@[CRS::ExclusionPolicy(:none)]
class Exclude
  include CrSerializer

  def initialize; end

  property name : String = "Jim"

  @[CRS::Exclude]
  property password : String? = "monkey"

  @[CRS::IgnoreOnSerialize]
  property ignored_serialize : Bool = false

  @[CRS::IgnoreOnDeserialize]
  property ignored_deserialize : Bool = true
end
