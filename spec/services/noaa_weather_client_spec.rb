require 'rails_helper'

RSpec.describe NoaaWeatherClient, type: :model do
  subject(:client) { described_class.new(lat, long) }

  let(:points_response) { Rails.root.join("spec", "fixtures", "points.json") }
  let(:forecast_response) { Rails.root.join("spec", "fixtures", "forecast.json") }
  let(:forecast_hourly_response) { Rails.root.join("spec", "fixtures", "forecast_hourly.json") }

  # Columbus, OH
  let(:lat) { '40.0220293' }
  let(:long) { '-83.027465' }

  # stub requests to NOAA weather service
  let!(:points_request) do
    stub_request(:get, "https://api.weather.gov/points/40.0220293,-83.027465").
      to_return(body: points_response, status: 200)
  end

  let!(:forecast_request) do
    stub_request(:get, "https://api.weather.gov/gridpoints/ILN/84,84/forecast").
      to_return(body: forecast_response, status: 200)
  end

  let!(:forecast_hourly_request) do
    stub_request(:get, "https://api.weather.gov/gridpoints/ILN/84,84/forecast/hourly").
      to_return(body: forecast_hourly_response, status: 200)
  end

  describe ".initialize" do
    it "has latitude and longitude" do
      expect(client.lat).to eq(lat)
      expect(client.long).to eq(long)
    end
  end

  describe "#forecast" do
    it "makes a request to get the forecast URL" do
      client.forecast
      expect(points_request).to have_been_made
      expect(forecast_request).to have_been_made
    end
  end

  describe "#forecast_hourly" do
    it "makes a request to get the forecast URL" do
      client.forecast_hourly
      expect(points_request).to have_been_made
      expect(forecast_hourly_request).to have_been_made
    end
  end

  describe "#combined_forecast" do
    it "prepares a ForecastResult" do
      expect(client.combined_forecast).to be_a(ForecastResult)
    end
  end

  # class level methods for convenience
  describe ".forecast_for" do
    it "makes a request to get the forecast URL" do
      described_class.forecast_for(lat, long)
      expect(points_request).to have_been_made
      expect(forecast_request).to have_been_made
    end
  end

  describe ".forecast_hourly_for" do
    it "makes a request to get the forecast URL" do
      described_class.forecast_hourly_for(lat, long)
      expect(points_request).to have_been_made
      expect(forecast_hourly_request).to have_been_made
    end
  end

  context "when the request isn't successful" do
    before do
      stub_request(:get, "https://api.weather.gov/gridpoints/ILN/84,84/forecast").
        to_return(body: ''.to_json, status: 500)
    end

    it "raises a NoaaWeatherClientError" do
      expect { client.combined_forecast }.to raise_error(NoaaWeatherClient::NoaaWeatherClientError)
    end
  end
end
