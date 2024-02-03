# frozen_string_literal: true

module Services
  module Geolocation
    class CensusAddressToGeo < Services::NetworkService
      DEFAULT_RETURN_TYPE = 'locations'
      DEFAULT_SEARCH_TYPE = 'address'

      validates :city,   presence: true, if: -> { zip.blank? }
      validates :state,  presence: true, if: -> { zip.blank? }
      validates :street, presence: true
      validates :zip,    presence: true, if: -> { city.blank? || state.blank? }

      def execute
        super
          .dig('result', 'addressMatches')
          .first['coordinates']
          .with_indifferent_access
          .tap do |data|
            context.latitude  = data[:x]
            context.longitude = data[:y]
          end
      end

      private

      def benchmark
        configuration.fetch :benchmark, 'Public_AR_Current'
      end

      def params
        {
          benchmark: benchmark,
          city:      city,
          format:    :json,
          street:    street,
          state:     state,
          zip:       zip
        }.compact
      end

      def path
        File.join(base_path, return_type, search_type).to_s
      end

      def return_type
        configuration.fetch :return_type, DEFAULT_RETURN_TYPE
      end

      def search_type
        configuration.fetch :search_type, DEFAULT_SEARCH_TYPE
      end
    end
  end
end
