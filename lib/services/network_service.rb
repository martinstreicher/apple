# frozen_string_literal: true

require 'addressable/uri'
require 'net/http'

module Services
  class NetworkService # rubocop:disable Metrics/ClassLength
    include Callable

    ALL_NET_HTTP_ERRORS =
      [
        Errno::EINVAL,
        Errno::ECONNRESET,
        EOFError,
        Net::HTTPBadResponse,
        Net::HTTPHeaderSyntaxError,
        Net::ProtocolError,
        Timeout::Error
      ].freeze

    CACHE_KEY_SEPARATOR  = '/'
    DEFAULT_CACHE_EXPIRY = 30.minutes.freeze
    DEFAULT_HOSTNAME     = 'localhost'
    DEFAULT_PROTOCOL     = 'http'

    def execute
      context.cached = false

      if cache_off? || cache_key.blank?
        return response_body if response_code == 200

        fail! response_body
      end

      value = Rails.cache.read(cache_key)
      if value
        context.cached = true
        return value
      end

      Rails.cache.write(cache_key, response_body, expires_in: cache_expiry)
      response_body
    end

    private

    def cache_expiry
      ENV.fetch('WEATHER_CACHE_EXPIRY_IN_SECONDS', DEFAULT_CACHE_EXPIRY).to_i
    end

    def cache_key
      Array.wrap(cache_key_segments).join(CACHE_KEY_SEPARATOR)
    end

    def cache_key_segments
      uri.to_s
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
      configuration.fetch(:debug, ENV['WEATHER_DEBUG_HTTP'].presence).to_boolean
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
      configuration.fetch :verb, :get
    end

    def path
      configuration.fetch :path, nil
    end

    def params
      {}
    end

    def port
      configuration.fetch :port, nil
    end

    def protocol
      configuration.fetch :protocol, DEFAULT_PROTOCOL
    end

    memoize def response
      http.request request
    rescue *ALL_NET_HTTP_ERRORS => e
      fail! e
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
          req.basic_auth(
            basic_authentication[:username],
            basic_authentication[:password]
          )
        end

        headers.each_pair do |header, value|
          req[header] = value
        end
      end
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
