class ExtendedForecastComponent < ViewComponent::Base
  def initialize(forecast_partial_days:)
    @forecast_partial_days = forecast_partial_days
  end
end
