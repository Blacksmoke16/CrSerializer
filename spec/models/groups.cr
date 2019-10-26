class Group
  include CrSerializer

  def initialize; end

  @[CRS::Groups("list", "details")]
  property id : Int64 = 1

  @[CRS::Groups("list")]
  property comment_summaries : Array(String) = ["Sentence 1.", "Sentence 2."]

  @[CRS::Groups("details")]
  property comments : Array(String) = ["Sentence 1.  Another sentence.", "Sentence 2.  Some other stuff."]

  property created_at : Time = Time.utc(2019, 1, 1)
end
