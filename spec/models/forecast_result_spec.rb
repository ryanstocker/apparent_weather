require 'rails_helper'

RSpec.describe ForecastResult, type: :model do
  subject(:forecast_result) { described_class.new(forecast, forecast_hourly) }

  let(:forecast) { JSON.parse(Rails.root.join("spec", "fixtures", "forecast.json").read) }
  let(:forecast_hourly) { JSON.parse(Rails.root.join("spec", "fixtures", "forecast_hourly.json").read) }

  describe 'days' do
    it "provides 7 days of data" do
      expect(forecast_result.days.size).to eq(7)
    end

    # if it's the 2nd part of the day, we won't have the morning forecast
    it "each day has at least 1 or 2 partial forecast items" do
      each_day_count = forecast_result.days.map(&:size)
      expect(each_day_count).to all(be_between(1,2))
    end

    it "all days are broken into ForecastPartialDay items" do
      expect(forecast_result.days.flatten).to all(be_a(ForecastPartialDay))
    end
  end

  # these are metaprogrammed
  context "important times methods" do
    it "are represented by a ForecastPartialDay" do
      [:walk_to_school, :recess, :walk_home].each do |important_time|
        expect(subject.send(important_time)).to be_a(ForecastPartialDay)
      end
    end

    describe "#walk_to_school" do
      it "returns the correct forecast for the walking to school" do
        forecast = subject.walk_to_school
        expect(forecast.short_forecast).to eq("Rain")
        expect(forecast.temperature).to eq(45)
      end
    end

    describe "#recess" do
      it "returns the correct forecast for recess" do
        forecast = subject.recess
        expect(forecast.short_forecast).to eq("Cloudy")
        expect(forecast.temperature).to eq(49)
      end
    end

    describe "#walk_to_school" do
      it "returns the correct forecast for walking home" do
        forecast = subject.walk_home
        expect(forecast.short_forecast).to eq("Cloudy")
        expect(forecast.temperature).to eq(51)
      end
    end
  end
end
