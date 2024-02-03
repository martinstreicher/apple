class ForecastsController < ApplicationController
  def create
    @forecast = Services::Controllers::ForecastShowService.call(forecast_params)

    if @forecast.success?
      render :show
    else
      render :new
    end
  end

  def new
    @forecast = Forecast.new
  end

  private

  def forecast_params
    params
      .require(:forecast)
      .permit(:city, :state, :street, :zip)
  end
end
