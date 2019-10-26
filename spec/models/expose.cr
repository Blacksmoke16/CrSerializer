@[CRS::ExclusionPolicy(:all)]
class Expose
  include CrSerializer

  def initialize; end

  @[CRS::Expose]
  property name : String = "Jim"

  property password : String? = "monkey"
end
