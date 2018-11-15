require "./assertion"
require "uuid"

module CrSerializer::Assertions
  # Validates a string is a properly formatted RFC4122 UUID; either in hyphenated, hexstring, or urn formats.
  #
  # Usable on only `String` properties
  #
  # Optional annotation fields:
  # * versions : `Array(UUID::Version)` - Only allow specific UUID versions. Default `[UUID::Version::V1, UUID::Version::V2, UUID::Version::V3, UUID::Version::V4, UUID::Version::V5]`.
  # * variants : `Array(UUID::Variant)` - Only allow specific UUID variants. Default `[UUID::Variant::RFC4122].
  # * strict : `Bool` - Only allow the hyphenated UUID format. Default `false`.
  #
  # ```
  # @[Assert::Uuid]
  # property data : String
  # ```
  #
  # NOTE: Nil values are considered valid
  class UuidAssertion(ActualValueType) < Assertion
    @message : String = "'{{field}}' is not a valid UUID"

    def initialize(
      field : String,
      message : String?,
      @actual : String?,
      @versions : Array(UUID::Version) = [UUID::Version::V1, UUID::Version::V2, UUID::Version::V3, UUID::Version::V4, UUID::Version::V5],
      @variants : Array(UUID::Variant) = [UUID::Variant::RFC4122],
      @strict : Bool = false
    )
      super field, message
    end

    def valid? : Bool
      act : String? = @actual
      return true if act.nil?
      if @strict
        return false unless act[8] == '-' && act[13] == '-' && act[18] == '-' && act[23] == '-'
      end
      uuid : UUID = UUID.new act
      return false unless @variants.any? { |v| v == uuid.variant }
      @versions.any? { |v| v == uuid.version }
    rescue e : ArgumentError
      false
    end
  end
end
