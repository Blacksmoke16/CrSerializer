class ReadOnly
  include CrSerializer

  def initialize; end

  property name : String = "name"

  @[CRS::ReadOnly]
  property password : String? = nil
end
