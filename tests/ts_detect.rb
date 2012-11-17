# -*- coding: utf-8 -*-
require 'test_helper'

class GAPI::DetectTest < Test::Unit::TestCase
  include Google::Language

  def setup
    assert_not_nil ENV['GAPI_KEY'], "Google translate API no longer available without API key"
  end


  def test_language_detection
    assert_equal("ARABIC", detect_it("مرحبا العالم"));
    assert_equal("CHINESE_SIMPLIFIED", detect_it("世界您好"));
    assert_equal("FRENCH", detect_it("Bonjour le monde"));
    assert_equal("GERMAN", detect_it("Hallo Welt"));
    assert_equal("ITALIAN", detect_it("Ciao mondo"));
    assert_equal("JAPANESE", detect_it("こんにちは世界"));
    assert_equal("KOREAN", detect_it("여보세요 세계"));
    assert_equal("PORTUGUESE", detect_it("Olá mundo"));
    assert_equal("RUSSIAN", detect_it("Привет мир"));
    assert_equal("SPANISH", detect_it("Hola mundo"));
  end

  private

  def detect_it(text)
    Languages[GAPI::Language.d(text)[:language]]
  end
end
