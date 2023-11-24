require "rails_helper"

RSpec.describe "Contracts Index", type: :system do
  let(:forecast) { JSON.parse(Rails.root.join("spec", "fixtures", "forecast.json").read) }
  let(:forecast_hourly) { JSON.parse(Rails.root.join("spec", "fixtures", "forecast_hourly.json").read) }
  let(:forecast_result) { ForecastResult.new(forecast, forecast_hourly) }
  let(:weather_service_double) { instance_double(WeatherService) }

  before do
    allow(WeatherService).to receive(:new).and_return(weather_service_double)
    allow(weather_service_double).to receive(:forecast_result).and_return(forecast_result)
  end

  context "getting the weather forcast for an address" do
    it "shows the important times and extended forecast" do
      visit root_path

      fill_in('forecast_location', with: "222 Ocean View Par")
      expect(page).to have_content("222 Ocean View ParkwayLewes, DE, USA")
      first('span', text: 'Ocean View Parkway').click
      # workaround for waiting for stimulus to populate hidden input fields
      find(:css, "#latitude[value='38.5432584']", visible: false)

      click_button("Get Forecast")
      within "#forecast_result" do
        expect(page).to have_content("Rain")
      end

      within "#walk-to-school" do
        expect(page).to have_content('Rain')
        expect(page).to have_content('45 F')
      end

      within "#recess" do
        expect(page).to have_content('Cloudy')
        expect(page).to have_content('49 F')
      end

      within "#walk-home" do
        expect(page).to have_content('Cloudy')
        expect(page).to have_content('51 F')
      end

      within "#extended_forecast" do
        # includes all extended data in the table
        forecast_result.days.flatten.map do |d|
           [d.name, d.detailed_forecast, d.temperature]
        end.flatten.each do |item|
          expect(page).to have_content(item)
        end
      end
    end

    describe "displaying cache info" do
      context "when not cached" do
        before do
          allow(forecast_result).to receive(:cached?).and_return(false)
        end

        it "displays when cached" do
          visit root_path

          fill_in('forecast_location', with: "222 Ocean View Par")
          first('span', text: 'Ocean View Parkway').click
          # workaround for waiting for stimulus to populate hidden input fields
          find(:css, "#latitude[value='38.5432584']", visible: false)

          click_button("Get Forecast")
          within "#forecast_result" do
            expect(page).to have_content("Forecast is not cached")
          end
        end
      end

      context "when cached" do
        before do
          allow(forecast_result).to receive(:cached?).and_return(true)
        end

        it "displays forecast is cached" do
          visit root_path

          fill_in('forecast_location', with: "222 Ocean View Par")
          first('span', text: 'Ocean View Parkway').click
          # workaround for waiting for stimulus to populate hidden input fields
          find(:css, "#latitude[value='38.5432584']", visible: false)

          click_button("Get Forecast")
          within "#forecast_result" do
            expect(page).to have_content("Forecast is cached")
          end
        end
      end
    end
  end

  context "when an error occurs" do
    before do
      allow(weather_service_double).to receive(:forecast_result).and_raise(
        NoaaWeatherClient::NoaaWeatherClientError
      )
    end
    let(:forecast_results) { NoaaWeatherClient::NoaaWeatherClientError }

    it "displays an error notice" do
      visit root_path

      fill_in('forecast_location', with: "222 Ocean View Par")
      expect(page).to have_content("222 Ocean View ParkwayLewes, DE, USA")
      first('span', text: 'Ocean View Parkway').click
      # workaround for waiting for stimulus to populate hidden input fields
      find(:css, "#latitude[value='38.5432584']", visible: false)

      click_button("Get Forecast")
      within "#flash" do
        expect(page).to have_content("The NWS API service experienced a problem.")
      end
    end
  end
end
