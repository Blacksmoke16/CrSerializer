class IgnoreOnDeserialize
  include CrSerializer

  def initialize; end

  property name : String = "Fred"

  @[CRS::IgnoreOnDeserialize]
  property password : String = "monkey"
end
