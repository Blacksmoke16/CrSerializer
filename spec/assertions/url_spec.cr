require "../../spec_helper"

class UrlTest
  include CrSerializer

  @[Assert::Url]
  property url : String?
end

class UrlProtocolTest
  include CrSerializer

  @[Assert::Url(protocols: %w(ftp file git))]
  property url : String?
end

class UrlRelativeProtocolTest
  include CrSerializer

  @[Assert::Url(relative_protocol: true)]
  property url : String?
end

class UrlDefaultTest
  include CrSerializer

  @[Assert::Url]
  property url : String?
end

class UrlDefaultTestMessage
  include CrSerializer

  @[Assert::Url(message: "{{actual}} is not a valid URL")]
  property url : String?
end

VALID_URLS = [
  "http://a.pl",
  "http://www.google.com",
  "http://www.google.com.",
  "http://www.google.museum",
  "https://google.com/",
  "https://google.com:80/",
  "http://www.example.coop/",
  "http://www.test-example.com/",
  "http://www.example.com/",
  "http://example.fake/blog/",
  "http://example.com/?",
  "http://example.com/search?type=&q=url+validator",
  "http://example.com/#",
  "http://example.com/#?",
  "http://www.example.com/doc/current/book/validation.html#supported-constraints",
  "http://very.long.domain.name.com/",
  "http://localhost/",
  "http://myhost123/",
  "http://127.0.0.1/",
  "http://127.0.0.1:80/",
  "http://[::1]/",
  "http://[::1]:80/",
  "http://[1:2:3::4:5:6:7]/",
  "http://sãopaulo.com/",
  "http://xn--sopaulo-xwa.com/",
  "http://sãopaulo.com.br/",
  "http://xn--sopaulo-xwa.com.br/",
  "http://пример.испытание/",
  "http://xn--e1afmkfd.xn--80akhbyknj4f/",
  "http://مثال.إختبار/",
  "http://xn--mgbh0fb.xn--kgbechtv/",
  "http://例子.测试/",
  "http://xn--fsqu00a.xn--0zwm56d/",
  "http://例子.測試/",
  "http://xn--fsqu00a.xn--g6w251d/",
  "http://例え.テスト/",
  "http://xn--r8jz45g.xn--zckzah/",
  "http://مثال.آزمایشی/",
  "http://xn--mgbh0fb.xn--hgbk6aj7f53bba/",
  "http://실례.테스트/",
  "http://xn--9n2bp8q.xn--9t4b11yi5a/",
  "http://العربية.idn.icann.org/",
  "http://xn--ogb.idn.icann.org/",
  "http://xn--e1afmkfd.xn--80akhbyknj4f.xn--e1afmkfd/",
  "http://xn--espaa-rta.xn--ca-ol-fsay5a/",
  "http://xn--d1abbgf6aiiy.xn--p1ai/",
  "http://☎.com/",
  "http://username:password@example.com",
  "http://user.name:password@example.com",
  "http://username:pass.word@example.com",
  "http://user.name:pass.word@example.com",
  "http://user-name@example.com",
  "http://example.com?",
  "http://example.com?query=1",
  "http://example.com/?query=1",
  "http://example.com#",
  "http://example.com#fragment",
  "http://example.com/#fragment",
  "http://example.com/#one_more%20tes",
]

INVALID_URLS = [
  "google.com",
  "://google.com",
  "http ://google.com",
  "http:/google.com",
  "http://goog_le.com",
  "http://google.com::aa",
  "http://google.com:aa",
  "ftp://google.fr",
  "faked://google.fr",
  "http://127.0.0.1:aa/",
  "ftp://[::1]/",
  "http://[::1",
  "http://hello.☎/",
  "http://:password@example.com",
  "http://:password@@example.com",
  "http://username:passwordexample.com",
  "http://usern@me:password@example.com",
  "http://example.com/exploit.html?<script>alert(1);</script>",
  "http://example.com/exploit.html?hel lo",
  "http://example.com/exploit.html?not_a%hex",
  "http://",
  "ftp://google.com",
  "file://127.0.0.1",
  "git://[::1]/",
]

VALID_CUSTOM_PROTOCOLS = [
  "ftp://google.com",
  "file://127.0.0.1",
  "git://[::1]/",
]

VALID_RELATIVE_URLS = [
  "//google.com",
  "//example.fake/blog/",
  "//example.com/search?type=&q=url+validator",
]

INVALID_RELATIVE_URLS = [
  "/google.com",
  "//goog_le.com",
  "//google.com::aa",
  "//google.com:aa",
  "//127.0.0.1:aa/",
  "//[::1",
  "//hello.☎/",
  "//:password@example.com",
  "//:password@@example.com",
  "//username:passwordexample.com",
  "//usern@me:password@example.com",
  "//example.com/exploit.html?<script>alert(1);</script>",
  "//example.com/exploit.html?hel lo",
  "//example.com/exploit.html?not_a%hex",
  "//",
]

describe Assert::Url do
  describe "normal" do
    context "valid urls" do
      it "should all be valid" do
        VALID_URLS.each do |url|
          UrlTest.from_json(%({"url": "#{url}"})).validator.valid?.should be_true
        end
      end
    end

    context "invalid urls" do
      it "should all be invalid" do
        INVALID_URLS.each do |url|
          model = UrlTest.from_json(%({"url": "#{url}"}))
          model.validator.valid?.should be_false
          model.validator.errors.size.should eq 1
          model.validator.errors.first.should eq "'url' is not a valid URL"
        end
      end
    end
  end

  describe "custom protocols" do
    context "valid urls" do
      it "should all be valid" do
        VALID_CUSTOM_PROTOCOLS.each do |url|
          UrlProtocolTest.from_json(%({"url": "#{url}"})).validator.valid?.should be_true
        end
      end
    end
  end

  describe "relative protocols" do
    context "with valid urls" do
      it "should all be valid" do
        VALID_RELATIVE_URLS.each do |url|
          UrlRelativeProtocolTest.from_json(%({"url": "#{url}"})).validator.valid?.should be_true
        end
      end
    end

    context "with invalid urls" do
      it "should all be invalid" do
        INVALID_RELATIVE_URLS.each do |url|
          model = UrlRelativeProtocolTest.from_json(%({"url": "#{url}"}))
          model.validator.valid?.should be_false
          model.validator.errors.size.should eq 1
          model.validator.errors.first.should eq "'url' is not a valid URL"
        end
      end
    end
  end

  describe "default" do
    context "with valid urls" do
      it "should all be valid" do
        VALID_URLS.each do |url|
          UrlDefaultTest.from_json(%({"url": "#{url}"})).validator.valid?.should be_true
        end
      end
    end

    context "with invalid urls" do
      context "without a custom message" do
        it "should all be invalid" do
          INVALID_URLS.each do |url|
            model = UrlDefaultTest.from_json(%({"url": "#{url}"}))
            model.validator.valid?.should be_false
            model.validator.errors.size.should eq 1
            model.validator.errors.first.should eq "'url' is not a valid URL"
          end
        end
      end

      context "with a custom message" do
        it "should return proper error message" do
          INVALID_URLS.each do |url|
            model = UrlDefaultTestMessage.from_json(%({"url": "#{url}"}))
            model.validator.valid?.should be_false
            model.validator.errors.size.should eq 1
            model.validator.errors.first.should eq "#{url} is not a valid URL"
          end
        end
      end
    end

    context "with null urls" do
      it "should be valid" do
        UrlDefaultTest.from_json(%({"url": null})).validator.valid?.should be_true
      end
    end
  end
end
