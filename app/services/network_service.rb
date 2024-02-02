# frozen_string_literal: true

require 'addressable/uri'
require 'net/http'

module Services
  class NetworkService
    include Callable

    CACHE_KEY_SEPARATOR  = '/'
    DEFAULT_CACHE_EXPIRY = 60 * 60
    DEFAULT_HOSTNAME     = 'localhost'
    DEFAULT_PORT         = 80
    DEFAULT_PROTOCOL     = 'http'

    def execute; end

    private

    def cache_expiry
      ENV.integer('SHOPIFY_CACHE_EXPIRY_IN_SECONDS', default: DEFAULT_CACHE_EXPIRY)
    end

    def cache_key
      cache_key_segments.join(CACHE_KEY_SEPARATOR)
    end

    def cache_off?
      ENV.fetch('WEATHER_CACHE_OFF', false).to_boolean
    end

    def base_path
      configuration.fetch :base_path, nil
    end

    def basic_authentication
      configuration.fetch :basic_auth, {}
    end

    def body; end

    def debug?
      configuration.fetch :debug, ENV['DEBUG_HTTP'].presence.to_boolean
    end

    def headers
      configuration
        .fetch(:headers, {})
        .transform_keys { |key| key.to_s.split('_').map(&:capitalize).join('-') }
        .transform_values(&:to_s)
    end

    def hostname
      configuration.fetch :hostname, DEFAULT_HOSTNAME
    end

    def http
      Net::HTTP.new(uri.host, uri.port).tap do |httpee|
        httpee.set_debug_output($stdout) if debug?
        httpee.use_ssl = uri.scheme == 'https'
      end
    end

    def http_verb
      configuration.fetch(:verb, :get)
    end

    def path
      configuration.fetch(:path, nil)
    end

    def params
      {}
    end

    def port
      configuration.fetch :port, DEFAULT_PORT
    end

    def protocol
      configuration.fetch :protocol, DEFAULT_PROTOCOL
    end

    memoize def response
      http.request request
    rescue *ALL_NET_HTTP_ERRORS => e
      raise RequestError, e.message
    end

    memoize def response_body
      JSON.parse response.body
    end

    memoize def response_code
      response.code.to_i
    end

    def request
      action = "Net::HTTP::#{http_verb.to_s.camelize}".constantize

      action.new(uri.request_uri).tap do |req|
        if body.present?
          if respond_to?(:body_as_json)
            req.body = body_as_json
          else
            req.set_form_data(body)
          end
        end

        if basic_authentication.presence
          req.basic_auth(basic_authentication[:username], basic_authentication[:password])
        end

        headers.each_pair do |header, value|
          req[header] = value
        end
      end
    end

    def segments
      []
    end

    memoize def uri
      target =
        configuration[:uri] ||
        ::Addressable::URI.new.tap do |uri|
          uri.hostname     = hostname
          uri.path         = path
          uri.port         = port
          uri.query_values = params
          uri.scheme       = protocol
        end

      URI.parse target
    end

    def use_cache?
      return false if cache_key.blank?
      return false if cache_off?

      true
    end
  end
end
