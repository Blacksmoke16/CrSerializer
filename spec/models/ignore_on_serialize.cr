class IgnoreOnSerialize
  include CrSerializer

  def initialize; end

  property name : String = "Fred"

  @[CRS::IgnoreOnSerialize]
  property password : String = "monkey"
end
