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
  def away
    @away ||= @data.dig(:teams, :away)
  end

  def complete?
    @data.dig(:status, :abstractGameState) == FINAL_STATE
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
  def home
    @home ||= @data.dig(:teams, :home)
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
    away.dig(:team, :id) < MAXIMUM_TEAM_ID &&
      home.dig(:team, :id) < MAXIMUM_TEAM_ID
  end

  # Return the game as JSON.
  #
  # @return [Hash]
  def as_json
    {
      away:     { id: away.dig(:team, :id).to_s, score: away.dig(:score) },
      home:     { id: home.dig(:team, :id).to_s, score: home.dig(:score) },
      start:    time,
      complete: complete?
    }
  end
end
