# -*- coding: utf-8 -*-
$:.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")

require 'test/unit'
require 'gapi'

class GAPI::SearchTest < Test::Unit::TestCase
  include Google::Language
  def test_search
    assert_equal("http://ruby-lang.org/", search_it("ruby"));
    assert_equal("http://forum.ruby-portal.de/", search_it("rubyforen"));
  end

  private
  
  def search_it(text)
    GAPI::Web.s(text)[0]['unescapedUrl']
  end
end
