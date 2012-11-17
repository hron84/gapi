# This is an unofficial ruby client API 
# for using the Google Search API
#
# Author::    Daniel Bovensiepen  (daniel@bovensiepen.net)
# Copyright:: Copyright (c) 2009 Daniel Bovensiepen
# License::   Distributes under MIT License

# This file was orignaly written by Dingding Ye (yedingding@gmail.com)

module GAPI
  class UnsupportedLanguagePair < StandardError
  end
  
  # This class is provides methods for Google Translate services
  #
  # It needs a Google API key. It should be provided both via parameter
  # and via environment variable. The environment variable name is GAPI_KEY
  #
  # Note:: static methods are 
  class Language
    # Google AJAX Language REST Service URL
    GOOGLE_TRANSLATE_URL = "https://www.googleapis.com/language/translate/v2"
    GOOGLE_DETECT_URL = "https://www.googleapis.com/language/translate/v2/detect"

    attr_reader :key
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

    def initialize(key = nil, default_from = nil, default_to = nil)
      @key = key || ENV['GAPI_KEY']
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

        url = "#{GOOGLE_TRANSLATE_URL}?q=#{text}&source=#{from}&target=#{to}"
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
      url = "#{GOOGLE_DETECT_URL}?q=#{text}"
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
        if response.key?('data')
          response["data"]["translations"].first['translatedText']
        else
          raise StandardError, response['error']['errors'].collect { |e| "#{e['message']}: #{e['reason']}" }.join(", ")
        end
      rescue Exception => e
        raise StandardError, e.message
      end
    end
    
    # sends json request to google and receive json response
    # "data": {
    #      "detections": [
    #       [
    #        {
    #         "language": the-detected-language,
    #         "isReliable": the-reliability-of-the-detect,
    #         "confidence": the-confidence-level-of-the-detect
    #        }
    #       ]
    #      ]
    #     }
    #    }
    # returns hash with response {:language, :is_reliable, :confidence}
    def do_detection(url) #:nodoc:
      begin
        jsondoc = open(URI.escape(url)).read
        response = JSON.parse(jsondoc)
        if response.key?('data')
          { language: response["data"]["detections"].flatten.first['language'], 
            is_reliable: response["data"]["detections"].flatten.first['language']["isReliable"], 
            confidence: response["data"]["detections"].flatten.first['language']["confidence"] }
        else
          p response
          raise StandardError, response['error']['errors'].collect { |e| "#{e['message']}: #{e['reason']}" }.join(", ")
        end
      rescue Exception => e
        raise StandardError, e.message
      end
    end
  end
end

module Google
  module Language
    Languages = {
      'af' => 'AFRIKAANS',
      'sq' => 'ALBANIAN',
      'am' => 'AMHARIC',
      'ar' => 'ARABIC',
      'hy' => 'ARMENIAN',
      'az' => 'AZERBAIJANI',

      'eu' => 'BASQUE',
      'be' => 'BELARUSIAN',
      'bn' => 'BENGALI',
      'bh' => 'BIHARI',
      'bg' => 'BULGARIAN',
      'my' => 'BURMESE',

      'ca' => 'CATALAN',
      'chr' => 'CHEROKEE',
      'zh' => 'CHINESE',
      'zh-CN' => 'CHINESE_SIMPLIFIED',
      'zh-TW' => 'CHINESE_TRADITIONAL',
      'hr' => 'CROATIAN',
      'cs' => 'CZECH',

      'da' => 'DANISH',
      'dv' => 'DHIVEHI',
      'nl' => 'DUTCH',

      'en' => 'ENGLISH',
      'eo' => 'ESPERANTO',
      'et' => 'ESTONIAN',

      'tl' => 'FILIPINO',
      'fi' => 'FINNISH',
      'fr' => 'FRENCH',

      'gl' => 'GALICIAN',
      'ka' => 'GEORGIAN',
      'de' => 'GERMAN',
      'el' => 'GREEK',
      'gn' => 'GUARANI',
      'gu' => 'GUJARATI',

      'iw' => 'HEBREW',
      'hi' => 'HINDI',
      'hu' => 'HUNGARIAN',

      'is' => 'ICELANDIC',
      'id' => 'INDONESIAN',
      'iu' => 'INUKTITUT',
      'it' => 'ITALIAN',

      'ja' => 'JAPANESE',

      'kn' => 'KANNADA',
      'kk' => 'KAZAKH',
      'km' => 'KHMER',
      'ko' => 'KOREAN',
      'ku' => 'KURDISH',
      'ky' => 'KYRGYZ',

      'lo' => 'LAOTHIAN',
      'lv' => 'LATVIAN',
      'lt' => 'LITHUANIAN',

      'mk' => 'MACEDONIAN',
      'ms' => 'MALAY',
      'ml' => 'MALAYALAM',
      'mt' => 'MALTESE',
      'mr' => 'MARATHI',
      'mn' => 'MONGOLIAN',

      'ne' => 'NEPALI',
      'no' => 'NORWEGIAN',

      'or' => 'ORIYA',

      'ps' => 'PASHTO',
      'fa' => 'PERSIAN',
      'pl' => 'POLISH',
      'pt' => 'PORTUGUESE',
      'pt-PT' => 'PORTUGUESE',
      'pa' => 'PUNJABI',

      'ro' => 'ROMANIAN',
      'ru' => 'RUSSIAN',

      'sa' => 'SANSKRIT',
      'sr' => 'SERBIAN',
      'sd' => 'SINDHI',
      'si' => 'SINHALESE',
      'sk' => 'SLOVAK',
      'sl' => 'SLOVENIAN',
      'es' => 'SPANISH',
      'sw' => 'SWAHILI',
      'sv' => 'SWEDISH',

      'tg' => 'TAJIK',
      'ta' => 'TAMIL',
      'tl' => 'TAGALOG',
      'te' => 'TELUGU',
      'th' => 'THAI',
      'bo' => 'TIBETAN',
      'tr' => 'TURKISH',

      'uk' => 'UKRAINIAN',
      'ur' => 'URDU',
      'uz' => 'UZBEK',
      'ug' => 'UIGHUR',

      'vi' => 'VIETNAMESE',

      '' => 'UNKNOWN'
    }

    # judge whether the language is supported by google translate
    def supported?(language)
      Languages.key?(language) || Languages.value?(language.upcase)
    end
    module_function :supported?

    # get the abbrev of the language
    def abbrev(language)
      if supported?(language)
        if Languages.key?(language)
          language
        else
          language.upcase!
          Languages.each do |k,v|
            if v == language
              return k
            end
          end
        end
      else
        nil
      end
    end
    module_function :abbrev
  end
end
