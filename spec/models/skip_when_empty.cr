class SkipWhenEmpty
  include CrSerializer

  def initialize; end

  @[CRS::SkipWhenEmpty]
  property value : String = "value"
end
