# frozen_string_literal: true

module Services
  module Geolocation
  end

  module Forecasting
  end

  module Weather
  end
end

require_relative 'callable'
require_relative 'network_service'
require_relative 'geolocation/census_address_to_geo'
require_relative 'weather/national_weather_service'
