require 'httparty'

module PageRankr
  class Request
    def initialize(tracker, options)
      @tracker = tracker
      @options = options
    end

    def perform
      method = tracker.method
      url = tracker.url

      response = HTTParty.send(method, url, construct_options(tracker))

      if response.body =~ /your computer or network may be sending automated queries/
        raise PageRankr::RequestThrottled, 'Request was throttled by tracker'
      else
        yield response.body if block_given?
      end
    end

  private
    attr_reader :tracker

    def construct_options(tracker)
      proxy = tracker.proxy
      params = tracker.params if tracker.respond_to?(:params)

      options = default_options
      options.merge!({
        :http_proxyaddr => proxy.host,
        :http_proxyport => proxy.port,
        :http_proxyuser => proxy.user,
        :http_proxypass => proxy.password
      }) if proxy
      options.merge!({:query => params}) if params
      options.merge!(@options)
    end

    def default_options
      {
        :headers => {
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/534.56.5 (KHTML, like Gecko) Version/5.1.6 Safari/534.56.5'
        }
      }
    end
  end
end