# frozen_string_literal: true

require "open-uri"
require "active_support"
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

  # Return if all games are postponed or not.
  #
  # @return [Boolean]
  def postponed?
    !games.empty? && games.values.flatten.all?(&:postponed?)
  end

  # Determine the starting date to query for.
  #
  # @return [Date]
  def start_date
    Date.current - 1.day
  end

  # Return the unique teams, sorted by their ID.
  #
  # @return [Hash]
  def teams
    @teams ||= games.each_with_object({}) do |(_, games), result|
      games.each do |game|
        away_team = game.away
        home_team = game.home

        result[away_team.dig(:team, :id)] ||=
          { name: away_team.dig(:team, :teamName) }
        result[home_team.dig(:team, :id)] ||=
          { name: home_team.dig(:team, :teamName) }
      end
    end.sort.to_h
  end

  # Return the schedule as JSON.
  #
  # @return [Hash]
  def as_json
    games.transform_values do |games|
      games.sort_by(&:start).map(&:as_json)
    end
  end

  private

  # Fetch and parse the schedule.
  #
  # @return [Hash]
  def dates
    @dates ||= JSON.parse(uri.read)["dates"]
  end

  # Build the request query.
  #
  # @return [String]
  def query
    {
      hydrate:   "team,broadcasts(all)",
      endDate:   end_date,
      startDate: start_date
    }.to_query
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
