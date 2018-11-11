require "./assertion"

module CrSerializer::Assertions
  # :nodoc:
  class DummyAssertion < Assertion
    getter message : String = ""

    def valid? : Bool
      true
    end
  end
end
