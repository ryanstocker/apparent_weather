class ForecastResultComponent < ViewComponent::Base
  def initialize(forecast_result:)
    @forecast_result = forecast_result
  end

  def render?
    @forecast_result.present?
  end
end
