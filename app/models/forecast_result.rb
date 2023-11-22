class ForecastResult
  IMPORTANT_TIMES = {
    walk_to_school: '08:40',
    recess: '13:20',
    walk_home: '15:40'
  }
  attr_accessor :cached, :days

  def initialize(forecast, forecast_hourly)
    @cached = false
    @forecast_hourly ||= forecast_hourly

    grouped_days = forecast['properties']['periods'].group_by do |day| 
      Date.parse(day['startTime'])
    end

    @days = grouped_days.values.map do |forecast_day_items|
      forecast_day_items.map do |forecast_half_day|
        ForecastPartialDay.new(forecast_half_day)
      end
    end
  end

  def cached?
    cached
  end

  # metaprogram methods to get forecasts for labeled times
  IMPORTANT_TIMES.each do |name, _v|
    define_method(name) do
      fetch_specific_forecast_for(name)
    end
  end

  private

  attr_reader :forecast_hourly

  def fetch_specific_forecast_for(key)
    raise StandardError.new, "#{key} not found in important times" unless IMPORTANT_TIMES.has_key?(key)
    matching_period = forecast_hourly['properties']['periods'].detect do |period|
      IMPORTANT_TIMES[key].between?(
        DateTime.parse(period['startTime']).strftime('%H:%M'), 
        DateTime.parse(period['endTime']).strftime('%H:%M')
      )
    end
    ForecastPartialDay.new(matching_period)
  end

end
