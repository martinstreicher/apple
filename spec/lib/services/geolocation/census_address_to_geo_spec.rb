# frozen_string_literal: true

module Services
  module Geolocation
    RSpec.describe CensusAddressToGeo do
      subject(:service) { described_class.call(params) }

      let(:params) do
        {
          street: '902 Daniels St',
          city:   'Raleigh',
          state:  'NC'
        }
      end

      describe 'given the default configuration' do
        subject(:service) { described_class.new(params) }

        it 'returns the correct path' do
          expect(service.send(:path))
            .to eq('geocoder/locations/address')
        end

        it 'returns the correct uri' do
          expect(service.send(:uri).to_s)
            .to include('https://geocoding.geo.census.gov/geocoder/locations/address?')
        end
      end

      describe 'given a street number, street name, city, and state' do
        it 'returns a successful response' do
          VCR.use_cassette('census_address_to_geo/street_city_state') do
            expect(service.success?).to be(true)
          end
        end
      end

      describe 'given a street number, street name, and a zip code' do
        let(:params) do
          {
            street: '331 NE 176',
            zip:    '33162'
          }
        end

        it 'returns a successful response' do
          VCR.use_cassette('census_address_to_geo/street_zip') do
            expect(service.success?).to be(true)

            expect(service.result)
              .to include('x' => -80.19426700143599, 'y' => 25.93663880232698)
          end
        end
      end

      describe 'given parameters with an empty street address' do
        let(:params) do
          super().merge(street: nil)
        end

        it 'returns a failure response' do
          expect(service).to be_failure
        end
      end

      describe 'given parameters with an empty state name' do
        let(:params) do
          super().merge(state: nil)
        end

        it 'returns a failure response' do
          expect(service).to be_failure
        end
      end

      describe 'given parameters with an empty city name' do
        let(:params) do
          super().merge(city: nil)
        end

        it 'returns a failure response' do
          expect(service).to be_failure
        end
      end
    end
  end
end
