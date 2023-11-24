class ForecastPartialDay
  attr_accessor :name, :temperature, :short_forecast, :detailed_forecast, :icon, :start_time, :end_time

  def initialize(forecast_partial)
    forecast_partial = forecast_partial.with_indifferent_access

    @name = forecast_partial['name']
    @start_time = DateTime.parse(forecast_partial['startTime'])
    @end_time = DateTime.parse(forecast_partial['endTime'])
    @temperature = forecast_partial['temperature']
    @short_forecast = forecast_partial['shortForecast']
    @detailed_forecast = forecast_partial['detailedForecast']
    @icon = forecast_partial['icon']
  end
end
