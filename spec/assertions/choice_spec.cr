require "../spec_helper"

class ChoiceTest
  include CrSerializer::Json

  @[CrSerializer::Assertions(choice: %w(John Steve))]
  property best_friend : String

  @[CrSerializer::Assertions(choice: [1, 2, 3])]
  property fav_number : Float32

  @[CrSerializer::Assertions(choice: [4, 5, 6])]
  property fav_number2 : Int32
end

describe "Assertions::Choice" do
  it "should be valid" do
    model = ChoiceTest.deserialize(%({"best_friend":"Steve","fav_number":2,"fav_number2":6}))
    model.validator.valid?.should be_true
  end

  it "should be invalid" do
    model = ChoiceTest.deserialize(%({"best_friend":"Josh","fav_number":-1,"fav_number2":15}))
    model.validator.valid?.should be_false
    model.validator.errors.size.should eq 3
    model.validator.errors.first.should eq "`Josh` is not a valid choice"
    model.validator.errors[1].should eq "`-1.0` is not a valid choice"
    model.validator.errors[2].should eq "`15` is not a valid choice"
  end
end
