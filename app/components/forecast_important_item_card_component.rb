class ForecastImportantItemCardComponent < ViewComponent::Base
  def initialize(title:, forecast_partial_day:)
    @title = title
    @forecast_partial_day = forecast_partial_day
  end

  def day_hint
    @forecast_partial_day.start_time.today? ? "(Today)" : "(Tomorrow)"
  end

  def forecast_image
    # sometimes the NWS service returns image URLs with ",<<number>>" in the URL
    # that return a 400 when accessed. Removing it results in a 200.
    # "small", "medium", and "large" are size options
    @forecast_partial_day.icon.gsub(/\,\d/,"").gsub("small","large")
  end
end
