class Skip
  include CrSerializer

  def initialize; end

  property one : String = "one"

  @[CRS::Skip]
  property two : String = "two"
end
