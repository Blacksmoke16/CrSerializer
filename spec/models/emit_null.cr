class EmitNil
  include CrSerializer

  def initialize; end

  property name : String?
  property age : Int32 = 1
end
