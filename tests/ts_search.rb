# -*- coding: utf-8 -*-

require 'test_helper'

class GAPI::SearchTest < Test::Unit::TestCase
  include Google::Language

  def test_search
    assert_equal("http://www.ruby-lang.org/", search_it("ruby"));
    assert_equal("http://forum.ruby-portal.de/", search_it("rubyforen"));
  end

  private

  def search_it(text)
    GAPI::Web.s(text)[0]['unescapedUrl']
  end
end
