class ReadOnly
  include CrSerializer

  property name : String

  @[CRS::ReadOnly]
  property password : String?
end
