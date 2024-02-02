# frozen_string_literal: true

module Services
  module Weather
    class NationalWeatherService < Services::NetworkService
      DEFAULT_PATH = 'points'

      validates :latitude,  presence: true
      validates :longitude, presence: true

      def execute
        debuggger
        1
      end

      private

      def coordinates
        "#{latitude},#{longitude}"
      end

      def path
        File.join(base_path, coordinates).to_s
      end
    end
  end
end
