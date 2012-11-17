# this is an unofficial ruby client API
# for using the Google Search API
#
# Author::    Daniel Bovensiepen  (daniel@bovensiepen.net)
# Copyright:: Copyright (c) 2009 Daniel Bovensiepen
# License::   Distributes under MIT License

module GAPI
  class Web
    GOOGLE_SEARCH_URL = "http://ajax.googleapis.com/ajax/services/search/web"

    class << self
      def search(text)
        Web.new.search(text)
      end

      alias_method :s, :search
    end

    def initialize(version = GAPI::DEFAULT_VERSION, key = nil)
      @version = version
      @key = key
    end

    # search in the web
    def search(text)
      url = "#{GOOGLE_SEARCH_URL}?q=#{text}&v=#{@version}"
      if @key
        url << "&key=#{@key}"
      end
      do_search(url)
    end

    # sends json request to google and receive json response
    #
    # JSON response by search for "Paris Hilton"
    # {"responseData": {
    #   "results": [
    #   {
    #     "GsearchResultClass": "GwebSearch",
    #     "unescapedUrl": "http://en.wikipedia.org/wiki/Paris_Hilton",
    #     "url": "http://en.wikipedia.org/wiki/Paris_Hilton",
    #     "visibleUrl": "en.wikipedia.org",
    #     "cacheUrl": "http://www.google.com/search?q\u003dcache:TwrPfhd22hYJ:en.wikipedia.org",
    #     "title": "\u003cb\u003eParis Hilton\u003c/b\u003e - Wikipedia, the free encyclopedia",
    #     "titleNoFormatting": "Paris Hilton - Wikipedia, the free encyclopedia",
    #     "content": "\[1\] In 2006, she released her debut album..."
    #   },
    #   {
    #     "GsearchResultClass": "GwebSearch",
    #     "unescapedUrl": "http://www.imdb.com/name/nm0385296/",
    #     "url": "http://www.imdb.com/name/nm0385296/",
    #     "visibleUrl": "www.imdb.com",
    #     "cacheUrl": "http://www.google.com/search?q\u003dcache:1i34KkqnsooJ:www.imdb.com",
    #     "title": "\u003cb\u003eParis Hilton\u003c/b\u003e",
    #     "titleNoFormatting": "Paris Hilton",
    #     "content": "Self: Zoolander. Socialite \u003cb\u003eParis Hilton\u003c/b\u003e..."
    #   },
    #   ...
    #   ],
    #   "cursor": {
    #     "pages": [
    #       { "start": "0", "label": 1 },
    #       { "start": "4", "label": 2 },
    #       { "start": "8", "label": 3 },
    #       { "start": "12","label": 4 }
    #     ],
    #    "estimatedResultCount": "59600000",
    #    "currentPageIndex": 0,
    #    "moreResultsUrl": "http://www.google.com/search?oe\u003dutf8\u0026ie\u003dutf8..."
    #    }
    #  }
    #  , "responseDetails": null, "responseStatus": 200}
    #
    # returns array with results in a hash
    # {"GsearchResultClass", "unescapedUrl", "url", "visibleUrl",
    #  "cacheUrl", "title", "titleNoFormatting", "content"}
    def do_search(url) #:nodoc:
      begin
        uri = URI.parse(URI.escape(url))
        jsondoc = ""

        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        http.start do |http|
          rsp = http.get(uri.request_uri)
          if rsp.code.to_i > 399
            raise StandardError, rsp.message
          end
          jsondoc = rsp.body
        end

        response = JSON.parse(jsondoc)
        if response["responseStatus"] == 200
          response["responseData"]["results"]
        else
          raise StandardError, response["responseDetails"]
        end
      rescue Exception => e
        raise StandardError, e.message
      end
    end
  end
end