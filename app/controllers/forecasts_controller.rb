# frozen_string_literal: true

class ForecastsController < ApplicationController
  def create
    result = Services::Forecasting::Report.call(forecast_params)

    if result.success?
      render :show, locals: { cached: result.cached, forecast: result.forecast }
      return
    end

    render(
      :new,
      locals: {
        errors:   result.errors,
        forecast: Forecast.new(forecast_params)
      }
    )
  end

  def new; end

  private

  def forecast_params
    params
      .require(:forecast)
      .permit(:city, :state, :street, :zip)
  end
end
