class PreSerialize
  include CrSerializer

  def initialize; end

  getter name : String?
  getter age : Int32?

  @[CRS::PreSerialize]
  def set_name : Nil
    @name = "NAME"
  end

  @[CRS::PreSerialize]
  def set_age : Nil
    @age = 123
  end
end
