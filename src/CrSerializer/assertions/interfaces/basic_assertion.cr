require "./assertion"

module CrSerializer::Assertions
  # Base class for the basic assertions
  #
  # TODO:  Remove the `noop` property once a workaround to [this issue](https://github.com/crystal-lang/crystal/issues/6980) is found.
  abstract class BasicAssertion(T) < Assertion
    def initialize(field : String, message : String?, @actual : T, noop : Nil = nil)
      super field, message
    end
  end
end
