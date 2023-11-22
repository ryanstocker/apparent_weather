class WeatherService
  attr_reader :lat, :long, :zip

  def initialize(lat:, long:, zip:, provider: NoaaWeatherClient)
    @client = provider.new(lat, long)
    # we only want to use the first 5 digits for a cache key
    @zip = zip&.first(5)
  end

  def forecast_result
    cached_forecast || cache_forecast!
  end

  private

  def cached_forecast
    Rails.cache.read("forecast_#{zip}").tap do |forecast|
      forecast.cached = true if forecast
    end
  end

  def cache_forecast!
    # some locations do not return with a zip
    return client.combined_forecast unless zip.present?

    client.combined_forecast.tap do |forecast|
      Rails.cache.write("forecast_#{zip}", forecast, expires_in: 30.minutes)
    end
  end

  attr_reader :client
end
