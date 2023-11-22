class NoaaWeatherClient
  API_BASE_URL = 'https://api.weather.gov/'.freeze
  POINTS_ENDPOINT = 'points/'.freeze

  CONNECT_TIMEOUT = 10
  READ_TIMEOUT = 30

  NoaaWeatherClientError = Class.new(StandardError)

  attr_accessor :lat, :long

  def initialize(lat, long)
    @client = HTTP
      .follow
      .timeout(
        connect: CONNECT_TIMEOUT, read: READ_TIMEOUT,
      )
    @lat = lat
    @long = long
  end

  def forecast
    request(base_url: forecast_url)
  end

  def forecast_hourly
    request(base_url: forecast_hourly_url)
  end

  def combined_forecast
    ForecastResult.new(
      forecast,
      forecast_hourly,
    )
  end

  def self.forecast_for(lat, long)
    new(lat, long).forecast
  end

  def self.forecast_hourly_for(lat, long)
    new(lat, long).forecast_hourly
  end

  private

  attr_reader :client

  def points
    # format is: /points/lat,long
    specific_endpoint = POINTS_ENDPOINT + [lat, long].join(',')
    @points ||= request(endpoint: specific_endpoint)
  end

  def forecast_url
    points['properties']['forecast']
  end

  def forecast_hourly_url
    points['properties']['forecastHourly']
  end

  def request(method: :get, base_url: API_BASE_URL, endpoint: '', params: {})
    response = client.public_send(
      method,
      "#{base_url}#{endpoint}",
      params
    )
    return JSON.parse(response) if response.status.success?

    raise NoaaWeatherClientError.new, "Status: #{response.status}, response: #{response.body}"
  end
end
