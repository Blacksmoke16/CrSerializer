@[CRS::ExclusionPolicy(:all)]
class PostDeserialize
  include CrSerializer

  def initialize; end

  getter first_name : String?
  getter last_name : String?

  @[CRS::Expose]
  getter name : String = "First Last"

  @[CRS::PostDeserialize]
  def split_name : Nil
    @first_name, @last_name = @name.split(' ')
  end
end
