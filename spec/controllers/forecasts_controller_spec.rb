# frozen_string_literal: true

# See https://github.com/vcr/vcr/blob/20e6c2d3f6f6499725ec585053a0dd48f7d1b7f8/lib/vcr.rb#L203-L222
# for more information about `use_cassettes`

RSpec.describe ForecastsController do
  around do |example|
    cassettes =
      [
        { name: 'census_address_to_geo/street_zip' },
        { name: 'national_weather_service/forecast' }
      ]

    VCR.use_cassettes(cassettes) do
      example.run
    end
  end

  let(:params) { { forecast: address_params } }

  describe 'when given a valid address' do
    let(:address_params) do
      {
        street: '331 NE 176',
        zip: '33162'
      }
    end

    it 'returns 200' do
      post :create, params: params
      expect(response).to have_http_status(200)
    end
  end
end
