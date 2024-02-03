# frozen_string_literal: true

module Services
  module Weather
    RSpec.describe NationalWeatherService do
      subject(:service) { described_class.call(latitude: latitude, longitude: longitude) }

      let(:latitude)  { 25.9366 }
      let(:longitude) { -80.1942 }

      describe 'given valid latitude and longitude' do
        subject(:service) { described_class.new(latitude: latitude, longitude: longitude) }

        it 'generates the proper URI' do
          expect(service.send(:uri).to_s)
            .to eq("https://api.weather.gov/points/#{latitude},#{longitude}?")
        end

        it 'retrieves the forecast' do
          VCR.use_cassette('national_weather_service/forecast') do
            service.execute
            expect(service.forecast).to be_a(Array)

            expect(service.forecast.first.to_h.keys)
              .to include('number', 'start_time', 'temperature', 'temperature_unit')
          end
        end
      end
    end
  end
end
