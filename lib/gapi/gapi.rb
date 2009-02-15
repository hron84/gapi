# this is an unofficial ruby client API 
# for using the Google Translation API
#
# Author::    Dingding Ye  (mailto:yedingding@gmail.com)
# Copyright:: Copyright (c) 2007 Dingding Ye
# License::   Distributes under MIT License
#
# this file was modified by Daniel Bovensiepen (daniel@bovensiepen.net)

module GAPI
  # Default version of Google AJAX API
  DEFAULT_VERSION = "1.0"
  
  class UnsupportedLanguagePair < StandardError
  end

  class Language
    # Google AJAX Language REST Service URL
    GOOGLE_TRANSLATE_URL = "http://ajax.googleapis.com/ajax/services/language/translate"
    GOOGLE_DETECT_URL = "http://ajax.googleapis.com/ajax/services/language/detect"

    attr_reader :version, :key
    attr_reader :default_from, :default_to

    class << self
      def translate(text, from, to)
        Language.new.translate(text, { :from => from, :to => to })
      end

      def translate_strings(text_array, from, to)
        Language.new.translate_strings(text_array, {:from => from, :to => to})
      end

      def translate_string_to_languages(text, options)
        Language.new.translate_string_to_languages(text, options)
      end

      def batch_translate(translate_options)
        Language.new.batch_translate(translate_options)
      end
      
      def detect(text)
        Language.new.detect(text)
      end

      alias_method :t, :translate
      alias_method :d, :detect
    end

    def initialize(version = GAPI::DEFAULT_VERSION, key = nil, default_from = nil, default_to = nil)
      @version = version
      @key = key
      @default_from = default_from
      @default_to = default_to

      if @default_from && !(Google::Lanauage.supported?(@default_from))
        raise StandardError, "Unsupported source language '#{@default_from}'"
      end

      if @default_to && !(Google::Lanauage.supported?(@default_to))
        raise StandardError, "Unsupported destination language '#{@default_to}'"
      end
    end

    # translate the string from a source language to a target language.
    #
    # Configuration options:
    # * <tt>:from</tt> - The source language
    # * <tt>:to</tt> - The target language
    def translate(text, options = { })
      from = options[:from] || @default_from
      to = options[:to] || @default_to
      if Google::Language.supported?(from) && Google::Language.supported?(to)
        from = Google::Language.abbrev(from)
        to = Google::Language.abbrev(to)
        langpair = "#{from}|#{to}"
        url = "#{GOOGLE_TRANSLATE_URL}?q=#{text}&langpair=#{langpair}&v=#{@version}"
        if @key
          url << "&key=#{@key}"
        end
        do_translate(url)
      else
        raise UnsupportedLanguagePair, "Translation from '#{from}' to '#{to}' isn't supported yet!"
      end
    end

    # translate several strings, all from the same source language to the same target language.
    #
    # Configuration options
    # * <tt>:from</tt> - The source language
    # * <tt>:to</tt> - The target language
    def translate_strings(text_array, options = { })
      text_array.collect do |text|
        self.translate(text, options)
      end
    end

    # Translate one string into several languages.
    #
    # Configuration options
    # * <tt>:from</tt> - The source language
    # * <tt>:to</tt> - The target language list
    # Example:
    #
    # translate_string_to_languages("China", {:from => "en", :to => ["zh-CN", "zh-TW"]})
    def translate_string_to_languages(text, option)
      option[:to].collect do |to|
        self.translate(text, { :from => option[:from], :to => to })
      end
    end

    # Translate several strings, each into a different language.
    #
    # Examples:
    #
    # batch_translate([["China", {:from => "en", :to => "zh-CN"}], ["Chinese", {:from => "en", :to => "zh-CN"}]])
    def batch_translate(translate_options)
      translate_options.collect do |text, option|
        self.translate(text, option)
      end
    end
    
    # detect the language of a given string
    def detect(text)
      url = "#{GOOGLE_DETECT_URL}?q=#{text}&v=#{@version}"
      if @key
        url << "&key=#{@key}"
      end
      do_detection(url)
    end

    private
    
    # sends language translation request to google and receive json response
    #
    # JSON response for translate language
    # {
    #   "responseData" : {
    #     "translatedText" : the-translated-text,
    #     "detectedSourceLanguage"? : the-source-language
    #   },
    #   "responseDetails" : null | string-on-error,
    #   "responseStatus" : 200 | error-code
    # }
    def do_translate(url) #:nodoc:
      begin
        jsondoc = open(URI.escape(url)).read
        response = JSON.parse(jsondoc)
        if response["responseStatus"] == 200
          response["responseData"]["translatedText"]
        else
          raise StandardError, response["responseDetails"]
        end
      rescue Exception => e
        raise StandardError, e.message
      end
    end
    
    # sends json request to google and receive json response
    #
    # JSON response for language detection
    # {
    #   "responseData" : {
    #     "language" : the-detected-language,
    #     "isReliable" : the-reliability-of-the-detect,
    #     "confidence" : the-confidence-level-of-the-detect
    #   },
    #   "responseDetails" : null | string-on-error,
    #   "responseStatus" : 200 | error-code
    # }
    #
    # returns hash with response {:language, :is_reliable, :confidence}
    def do_detection(url) #:nodoc:
      begin
        jsondoc = open(URI.escape(url)).read
        response = JSON.parse(jsondoc)
        if response["responseStatus"] == 200
          { language: response["responseData"]["language"], 
            is_reliable: response["responseData"]["isReliable"], 
            confidence: response["responseData"]["confidence"] }
        else
          raise StandardError, response["responseDetails"]
        end
      rescue Exception => e
        raise StandardError, e.message
      end
    end
  end
end
