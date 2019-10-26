class Default
  include CrSerializer

  def initialize; end

  property a : String = "A"
  property z : String = "Z"
  property two : String = "two"
  property one : String = "one"
  property a_a : Int32 = 123

  @[CRS::VirtualProperty]
  def get_val : String
    "VAL"
  end
end

@[CRS::AccessorOrder(:alphabetical)]
class Abc
  include CrSerializer

  def initialize; end

  property a : String = "A"
  property z : String = "Z"
  property one : String = "one"
  property a_a : Int32 = 123

  @[CRS::Name(serialize: "two")]
  property zzz : String = "two"

  @[CRS::VirtualProperty]
  def get_val : String
    "VAL"
  end
end

@[CRS::AccessorOrder(:custom, order: ["two", "z", "get_val", "a", "one", "a_a"])]
class Custom
  include CrSerializer

  def initialize; end

  property a : String = "A"
  property z : String = "Z"
  property two : String = "two"
  property one : String = "one"
  property a_a : Int32 = 123

  @[CRS::VirtualProperty]
  def get_val : String
    "VAL"
  end
end
