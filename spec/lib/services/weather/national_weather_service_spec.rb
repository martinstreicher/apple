# frozen_string_literal: true

module Services
  module Weather
    RSpec.describe NationalWeatherService do
      subject(:service) { described_class.call(latitude: latitude, longitude: longitude) }

      let(:latitude)  { 35.79621324351497 }
      let(:longitude) { -78.65663507332098 }

      describe 'given valid latitude and longitude' do
        subject { described_class.new(latitude: latitude, longitude: longitude) }

        it 'generates the proper URI' do
          expect(service.send(:uri).to_s)
            .to eq('https://api.weather.gov/points/35.7962,-78.6566??')
        end
      end
    end
  end
end
