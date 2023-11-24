
require 'rails_helper'

RSpec.describe WeatherService, type: :model do
  subject(:weather_service) { described_class.new(lat: lat, long: long, zip: zip) }

  # Columbus, OH
  let(:lat)  { '40.0220293' }
  let(:long) { '-83.027465' }
  let(:zip)  { '43210' }

  let(:noaa_weather_client) do 
    instance_double(NoaaWeatherClient, combined_forecast: combined_forecast)
  end
  let(:forecast) { JSON.parse(Rails.root.join("spec", "fixtures", "forecast.json").read) }
  let(:forecast_hourly) { JSON.parse(Rails.root.join("spec", "fixtures", "forecast_hourly.json").read) }
  let(:combined_forecast) do
    ForecastResult.new(forecast, forecast_hourly)
  end

  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
    allow(NoaaWeatherClient).to receive(:new).with(lat, long).and_return(noaa_weather_client)
  end

  it "caches the result" do
    expect {
      weather_service.forecast_result
    }.to change { Rails.cache.read("forecast_#{zip}")}.from(nil).to(ForecastResult)
  end
end
