class VirtualProperty
  include CrSerializer

  def initialize; end

  property foo : String = "foo"

  @[CRS::VirtualProperty]
  def get_val : String
    "VAL"
  end
end
