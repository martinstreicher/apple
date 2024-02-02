# frozen_string_literal: true

module Services
  module Forecasting
    class Report
      include Interactor::Organizer

      organize(
        Services::Geolocation::CensusAddressToGeo,
        Services::Weather::NationalWeatherService
      )
    end
  end
end
