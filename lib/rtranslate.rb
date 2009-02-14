# this file was modified by Daniel Bovensiepen (daniel@bovensiepen.net)

require File.join(File.dirname(__FILE__), 'rtranslate/language')
require File.join(File.dirname(__FILE__), 'rtranslate/rtranslate')
require 'uri'
require 'open-uri'

include Translate
def Translate.t(text, from, to)
  begin
    RTranslate.translate(text, from, to)
  rescue
    "Error: " + $!
  end
end

