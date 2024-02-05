# frozen_string_literal: true

module Services
  module Weather
    class NationalWeatherService < Services::NetworkService
      DEFAULT_PATH = 'points'

      validates :latitude,  presence: true
      validates :longitude, presence: true

      def execute
        target =
          super
          .with_indifferent_access
          .dig('properties', 'forecastHourly')

        result = retrieve_forecast(target)
        context.fail! if result.failure?

        periods          = result.result.dig('properties', 'periods')
        context.cached   = result.cached
        context.forecast = convert_to_period_records(periods)
      end

      private

      def convert_to_period_records(list_of_period_hashes)
        list_of_period_hashes.map do |period|
          ForecastPeriod.new(period)
        end
      end

      def coordinates
        "#{latitude.to_f.round(4)},#{longitude.to_f.round(4)}"
      end

      def path
        File.join(base_path, coordinates).to_s
      end

      def retrieve_forecast(uri)
        uri = URI.parse(uri)

        settings = {
          hostname: uri.hostname,
          path:     uri.path,
          protocol: uri.scheme
        }

        Services::NetworkService.call(settings: settings)
      end
    end
  end
end
