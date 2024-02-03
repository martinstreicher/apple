RSpec.describe ForecastPeriod do
  subject(:forecast_period) { described_class.new(period) }

  describe 'given a hash representing a forecast period', :aggregate_failures do
    let(:period) do
      {
        'startTime'   => start_time,
        'temperature' => temperature,
        'windSpeed'   => wind_speed
      }
    end

    let(:start_time)     { Time.zone.now.to_s }
    let(:temperature)    { 75 }
    let(:wind_speed)     { 10 }

    it 'returns start_time as a Time' do
      expect(forecast_period.start_time).to eq(Time.zone.parse(start_time))
    end

    it 'responds to temperature' do
      expect(forecast_period).to respond_to(:temperature)
      expect(forecast_period.temperature).to eq(temperature)
    end

    it 'changes property names to snake_case' do
      expect(forecast_period).to respond_to(:wind_speed)
      expect(forecast_period.wind_speed).to eq(wind_speed)
    end

    it 'does not respond to rain_fall' do
      expect(forecast_period).not_to respond_to(:rain_fall)
      expect { forecast_period.rain_fall }.to raise_error(NoMethodError)
    end
  end
end
