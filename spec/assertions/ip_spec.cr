require "../../spec_helper"

class IPV4Test
  include CrSerializer::Json

  @[Assert::IP(version: CrSerializer::Assertions::IPVersion::IPV4)]
  property ip : String?
end

class IPV6Test
  include CrSerializer::Json

  @[Assert::IP(version: CrSerializer::Assertions::IPVersion::IPV6)]
  property ip : String?
end

class IPDefaultTest
  include CrSerializer::Json

  @[Assert::IP]
  property ip : String?
end

class IPDefaultMessageTest
  include CrSerializer::Json

  @[Assert::IP(message: "{{actual}} is not a valid IP address")]
  property ip : String?
end

VALID_IPV4 = [
  "0.0.0.0",
  "10.0.0.0",
  "123.45.67.178",
  "172.16.0.0",
  "192.168.1.0",
  "224.0.0.1",
  "255.255.255.255",
  "127.0.0.0",
]

INVALID_IPV4 = [
  "0",
  "0.0",
  "0.0.0",
  "256.0.0.0",
  "0.256.0.0",
  "0.0.256.0",
  "0.0.0.256",
  "-1.0.0.0",
  "foobar",
]

VALID_IPV6 = [
  "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
  "2001:0DB8:85A3:0000:0000:8A2E:0370:7334",
  "2001:0Db8:85a3:0000:0000:8A2e:0370:7334",
  "fdfe:dcba:9876:ffff:fdc6:c46b:bb8f:7d4c",
  "fdc6:c46b:bb8f:7d4c:fdc6:c46b:bb8f:7d4c",
  "fdc6:c46b:bb8f:7d4c:0000:8a2e:0370:7334",
  "fe80:0000:0000:0000:0202:b3ff:fe1e:8329",
  "fe80:0:0:0:202:b3ff:fe1e:8329",
  "fe80::202:b3ff:fe1e:8329",
  "0:0:0:0:0:0:0:0",
  "::",
  "0::",
  "::0",
  "0::0",
  # IPv4 mapped to IPv6
  "2001:0db8:85a3:0000:0000:8a2e:0.0.0.0",
  "::0.0.0.0",
  "::255.255.255.255",
  "::123.45.67.178",
]

INVALID_IPV6 = [
  "z001:0db8:85a3:0000:0000:8a2e:0370:7334",
  "fe80",
  "fe80:8329",
  "fe80:::202:b3ff:fe1e:8329",
  "fe80::202:b3ff::fe1e:8329",
  # IPv4 mapped to IPv6
  "2001:0db8:85a3:0000:0000:8a2e:0370:0.0.0.0",
  "::0.0",
  "::0.0.0",
  "::256.0.0.0",
  "::0.256.0.0",
  "::0.0.256.0",
  "::0.0.0.256",
]

describe Assert::IP do
  describe CrSerializer::Assertions::IPVersion::IPV4 do
    context "with valid IPV4 addresses" do
      it "should all be valid" do
        VALID_IPV4.each do |ip|
          IPV4Test.deserialize(%({"ip": "#{ip}"})).validator.valid?.should be_true
        end
      end
    end

    context "with invalid IPV4 addresses" do
      it "should all be invalid" do
        INVALID_IPV4.each do |ip|
          model = IPV4Test.deserialize(%({"ip": "#{ip}"}))
          model.validator.valid?.should be_false
          model.validator.errors.size.should eq 1
          model.validator.errors.first.should eq "'ip' is not a valid IP address"
        end
      end
    end
  end

  describe CrSerializer::Assertions::IPVersion::IPV6 do
    context "with valid IPV6 addresses" do
      it "should all be valid" do
        VALID_IPV6.each do |ip|
          IPV6Test.deserialize(%({"ip": "#{ip}"})).validator.valid?.should be_true
        end
      end
    end

    context "with invalid IPV6 addresses" do
      it "should all be invalid" do
        INVALID_IPV6.each do |ip|
          model = IPV6Test.deserialize(%({"ip": "#{ip}"}))
          model.validator.valid?.should be_false
          model.validator.errors.size.should eq 1
          model.validator.errors.first.should eq "'ip' is not a valid IP address"
        end
      end
    end
  end

  describe "default" do
    context "with valid IPV4 addresses" do
      it "should all be valid" do
        VALID_IPV4.each do |ip|
          IPDefaultTest.deserialize(%({"ip": "#{ip}"})).validator.valid?.should be_true
        end
      end
    end

    context "with invalid emails" do
      context "without a custom message" do
        it "should all be invalid" do
          INVALID_IPV4.each do |ip|
            model = IPDefaultTest.deserialize(%({"ip": "#{ip}"}))
            model.validator.valid?.should be_false
            model.validator.errors.size.should eq 1
            model.validator.errors.first.should eq "'ip' is not a valid IP address"
          end
        end
      end

      context "with a custom message" do
        it "should return proper error message" do
          INVALID_IPV4.each do |ip|
            model = IPDefaultMessageTest.deserialize(%({"ip": "#{ip}"}))
            model.validator.valid?.should be_false
            model.validator.errors.size.should eq 1
            model.validator.errors.first.should eq "#{ip} is not a valid IP address"
          end
        end
      end
    end

    context "with null email" do
      it "should be valid" do
        IPDefaultTest.deserialize(%({"email": null})).validator.valid?.should be_true
      end
    end
  end
end
