@[CRS::ExclusionPolicy(:none)]
class Exclude
  include CrSerializer

  def initialize; end

  property name : String = "Jim"

  @[CRS::Exclude]
  property password : String? = "monkey"
end
