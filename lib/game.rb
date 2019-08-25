# frozen_string_literal: true

class Game
  FINAL_STATE     = "Final"
  MAXIMUM_TEAM_ID = 100

  def initialize(data)
    @data = data.deep_symbolize_keys.slice(:gameDate, :teams, :status)
  end

  # Extract the away team data.
  #
  # @return [Hash]
  def away_team
    @away_team ||= @data.dig(:teams, :away, :team)
  end

  # Return the date of the game.
  #
  # @return [Date]
  def date
    @date ||= time.to_date
  end

  # Extract the home team data.
  #
  # @return [Hash]
  def home_team
    @home_team ||= @data.dig(:teams, :home, :team)
  end

  # Extract and parse the game time.
  #
  # @return [Time]
  def time
    @time ||= Time.zone.parse(@data[:gameDate])
  end

  # Determine if the game is valid.
  #
  # @return [Boolean]
  def valid?
    away_team[:id] < MAXIMUM_TEAM_ID &&
      home_team[:id] < MAXIMUM_TEAM_ID &&
      @data.dig(:status, :detailedState) != FINAL_STATE
  end

  # Return the game as JSON.
  #
  # @return [Hash]
  def as_json
    {
      away:  away_team[:id].to_s,
      home:  home_team[:id].to_s,
      start: time
    }
  end
end
