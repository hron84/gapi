# this is an unofficial ruby client API 
# for using the Google Search API
#
# Author::    Daniel Bovensiepen  (daniel@bovensiepen.net)
# Copyright:: Copyright (c) 2009 Daniel Bovensiepen
# License::   Distributes under MIT License
#
# this file was originally written by Dingding Ye (yedingding@gmail.com)

require 'json'
require 'uri'
require 'open-uri'
require File.join(File.dirname(__FILE__), 'gapi/language')
require File.join(File.dirname(__FILE__), 'gapi/web')

module GAPI
  # Default version of Google AJAX API
  DEFAULT_VERSION = "1.0"  
end