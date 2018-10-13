require "../spec_helper"

class UniqueTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(unique: true)]
  property fav_numbers : Array(Float32)

  @[CrSerializer::Assertions(unique: false)]
  property best_friends : Array(String)
end

describe "Assertions::Unique" do
  it "should be valid" do
    model = UniqueTest.deserialize(%({"best_friends":["Steve","John","Josh","Josh"],"fav_numbers":[1,2,3]}))
    model.validator.valid?.should be_true
  end

  it "should be invalid" do
    model = UniqueTest.deserialize(%({"best_friends":["Steve","John","Josh"],"fav_numbers":[1,2,1]}))
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 2
    model.validator.errors.first.should eq "`fav_numbers` should be unique"
    model.validator.errors[1].should eq "`best_friends` should not be unique"
  end
end
