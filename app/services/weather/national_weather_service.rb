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

        retrieve_forecast target
      end

      private

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

        Services::NetworkService
          .call(settings: settings)
          .result
          .dig('properties', 'periods')
      end
    end
  end
end
