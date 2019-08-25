# frozen_string_literal: true

require "open-uri"
require "active_support/core_ext"

class Schedule
  SCHEDULE_URL    = "https://statsapi.web.nhl.com/api/v1/schedule"
  DELIMITER_MONTH = 7

  # Initialize the schedule by setting the time zone.
  #
  # @param [String] zone The time zone for the schedule.
  def initialize(zone:)
    Time.zone = zone
  end

  # Return all the valid games on the schedule, grouped by date.
  #
  # @return [Hash]
  def games
    @games ||= dates.flat_map do |group|
      group["games"].map do |game|
        Game.new(game)
      end
    end.select(&:valid?).group_by(&:date)
  end

  # Return the unique teams, sorted by their ID.
  #
  # @return [Hash]
  def teams
    @teams ||= games.each_with_object({}) do |(_, games), result|
      games.each do |game|
        away_team = game.away_team
        home_team = game.home_team

        result[away_team[:id]] ||= { name: away_team[:teamName] }
        result[home_team[:id]] ||= { name: home_team[:teamName] }
      end
    end.sort.to_h
  end

  # Return the schedule as JSON.
  #
  # @return [Hash]
  def as_json
    games.each_with_object({}) do |(date, games), result|
      result[date] = games.sort_by(&:time).map(&:as_json)
    end
  end

  private

  # Fetch and parse the schedule.
  #
  # @return [Hash]
  def dates
    @dates ||= JSON.parse(uri.read).dig("dates")
  end

  # Determine the ending date to query for.
  #
  # If the month is at or beyond the delimiter month, July, then end the
  # following year on June 30th. Otherwise end on June 30th in the current
  # year.
  #
  # @return [Date]
  def end_date
    day   = Time.zone.today
    year  = day.year
    year += 1 if day.month >= DELIMITER_MONTH

    time = Time.zone.local(year, DELIMITER_MONTH, 1) - 1.day
    time.to_date
  end

  # Build the request query.
  #
  # @return [String]
  def query
    {
      hydrate:   "team",
      endDate:   end_date,
      startDate: start_date
    }.to_query
  end

  # Determine the starting date to query for.
  #
  # @return [Date]
  def start_date
    Date.current
  end

  # Generate a schedule URI with the dynamic query parameters.
  #
  # @return [URI]
  def uri
    uri = URI.parse(SCHEDULE_URL)
    uri.query = query
    uri
  end
end
