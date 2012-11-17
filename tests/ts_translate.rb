# -*- coding: utf-8 -*-
$:.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")

require 'test_helper'

class GAPI::TranslateTest < Test::Unit::TestCase
  include Google::Language

  def test_english_translate
    assert_equal("مرحبا العالم", translate_it("Hello world", "ENGLISH", "ARABIC"));
    # assert_equal("世界您好", translate_it("Hello world", "ENGLISH", "CHINESE_SIMPLIFIED"));
    assert_equal("Hallo Welt", translate_it("Hello world", "ENGLISH", "GERMAN"));
    assert_equal("Bonjour tout le monde", translate_it("Hello world", "ENGLISH", "FRENCH"));
    assert_equal("Ciao mondo", translate_it("Hello world", "ENGLISH", "ITALIAN"));
    # assert_equal("여보세요 세계", translate_it("Hello world", "ENGLISH", "KOREAN"));
    assert_equal("Olá, mundo", translate_it("Hello world", "ENGLISH", "PORTUGUESE"));
    assert_equal("Привет мир", translate_it("Hello world", "ENGLISH", "RUSSIAN"));
    assert_equal("Hola mundo", translate_it("Hello world", "ENGLISH", "SPANISH"));
  end

  def setup
    assert_not_nil ENV['GAPI_KEY'], "Google translate API no longer available without API key"
  end


  def test_chinese_translate
    assert_equal("Hello World", translate_it("你好世界", "CHINESE", "ENGLISH"))
    assert_equal("Hello World", translate_it("你好世界", 'zh', 'en'))
  end

  def test_unsupported_translate
    assert_raise GAPI::UnsupportedLanguagePair do
      translate_it("你好世界", 'zh', 'hz')
    end
  end

    def test_translate_strings
      assert_equal(["Hallo", "Welt"], GAPI::Language.translate_strings(["Hello", "World"],  "en", "de"))
    end
  #
  def test_translate_string_to_languages
     assert_equal ["Hallo Welt", "Ciao mondo"],
                 GAPI::Language.translate_string_to_languages("Hello world",
                                                             {:from => "en",
                                                               :to => ["de", "it"]
                                                             })
   end
  #
  # def test_batch_translate
  #   assert_equal(["世界您好", "ハローワールド"],
  #                GAPI::Language.batch_translate([["Hello World", {:from => "en", :to => "zh-CN"}], ["Hello World", {:from => "en", :to => "ja"}]]))
  # end
  #
  private

    def translate_it(text, from, to)
      GAPI::Language.t(text, from, to)
    end
end
