class ForecastsController < ApplicationController
  rescue_from NoaaWeatherClient::NoaaWeatherClientError, with: :show_api_error

  def index 
    if searching?
      @forecast_result = WeatherService.new(
        lat: forecast_params[:latitude],
        long: forecast_params[:longitude],
        zip: forecast_params[:postal_code]
      ).forecast_result
    end
  end

  def show_api_error
    redirect_to forecasts_url, notice: "The NWS API service experienced a problem. Sometimes trying again works!"
  end

  private

  def searching?
    forecast_params[:latitude].present? &&
    forecast_params[:longitude].present?
  end

  def forecast_params
    params.permit(:latitude, :longitude, :postal_code, :forecast_location)
  end
end
