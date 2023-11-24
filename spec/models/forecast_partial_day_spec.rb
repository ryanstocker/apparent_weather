require 'rails_helper'

RSpec.describe ForecastPartialDay, type: :model do
  subject(:forecast_partial_day) { described_class.new(hourly_forecast_part) }

  let(:hourly_forecast_part) do
    {
      number: 1,
      name: "",
      startTime: "2023-11-20T10:00:00-05:00",
      endTime: "2023-11-20T11:00:00-05:00",
      isDaytime: true,
      temperature: 42,
      temperatureUnit: "F",
      temperatureTrend: nil,
      probabilityOfPrecipitation: {
          unitCode: "wmoUnit:percent",
          value: 2
      },
      dewpoint: {
          unitCode: "wmoUnit:degC",
          value: 0.55555555555555558
      },
      relativeHumidity: {
          unitCode: "wmoUnit:percent",
          value: 70
      },
      windSpeed: "10 mph",
      windDirection: "NE",
      icon: "https://api.weather.gov/icons/land/day/ovc,2?size=small",
      shortForecast: "Cloudy",
      detailedForecast: "Detailed Forecast"
    }
  end

  describe 'attributes' do
    it 'has the correct data' do
      expect(forecast_partial_day.short_forecast).to eq("Cloudy")
      expect(forecast_partial_day.temperature).to eq(42)
      expect(forecast_partial_day.start_time).to eq(DateTime.parse("2023-11-20T10:00:00-05:00"))
      expect(forecast_partial_day.end_time).to eq(DateTime.parse("2023-11-20T11:00:00-05:00"))
      expect(forecast_partial_day.detailed_forecast).to eq("Detailed Forecast")
      expect(forecast_partial_day.icon).to eq("https://api.weather.gov/icons/land/day/ovc,2?size=small")
    end
  end
end
