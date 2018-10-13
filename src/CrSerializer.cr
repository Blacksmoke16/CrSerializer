require "./CrSerializer/**"

# TODO: Write documentation for `CrSerializer`
module CrSerializer
  annotation Options; end
  annotation Assertions; end

  VERSION = "0.1.0"

  # TODO: Put your code here
end

class Foo
  include CrSerializer::Json

  # def initialize(@name, @password, @age); end

  property name : String

  @[CrSerializer::Json::Options(readonly: true, emit_null: false)]
  property password : String?

  @[CrSerializer::Assertions(range: 0..100)]
  property age : Int32?

  @[CrSerializer::Json::Options(expose: false)]
  property friends : Array(String) = ["one", "two"]

  def getPwd
    "sdfwef"
  end
end

json_str = %({"name": "George", "age": 101, "password": "monkey"})

foo = Foo.deserialize(json_str)

pp foo
