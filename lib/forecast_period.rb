# frozen_string_literal: true

class ForecastPeriod
  def initialize(period)
    @period =
      period.transform_keys do |key|
        key.to_s.underscore
      end
  end

  def method_missing(method_name, *_args, &_block)
    period[method_name.to_s] || super
  end

  def respond_to_missing?(method_name, _include_private = false)
    period.key?(method_name.to_s) || super
  end

  def start_time
    Time.zone.parse period['start_time']
  end

  private

  attr_reader :period
end
