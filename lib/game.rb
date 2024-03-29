# frozen_string_literal: true

class Game
  COMPLETE_STATE  = "Final"
  MAXIMUM_TEAM_ID = 100
  POSTPONED_STATE = "Postponed"
  TBD_STATE = "Scheduled (Time TBD)"

  def initialize(data)
    @data = data.deep_symbolize_keys.slice(:broadcasts, :gameDate, :gamePk, :teams, :status)
  end

  # Extract the away team data.
  #
  # @return [Hash]
  def away
    @away ||= @data.dig(:teams, :away)
  end

  # Return the TV networks for the game.
  #
  # @return [Array]
  def networks
    Array(@data[:broadcasts]).map do |broadcast|
      broadcast[:name]
    end.sort
  end

  # Return if the game is complete or not.
  #
  # @return [Boolean]
  def complete?
    @data.dig(:status, :abstractGameState) == COMPLETE_STATE
  end

  # Return the date of the game.
  #
  # @return [Date]
  def date
    @date ||= start.to_date
  end

  # Extract the home team data.
  #
  # @return [Hash]
  def home
    @home ||= @data.dig(:teams, :home)
  end

  # Return an identifer for the game.
  #
  # @return [String]
  def id
    @data[:gamePk]
  end

  # Return if the game is postponed or not.
  #
  # @return [Boolean]
  def postponed?
    @data.dig(:status, :detailedState) == POSTPONED_STATE
  end

  # Extract and parse the game time.
  #
  # If the game time is TBD, the time is removed and returned in UTC.
  #
  # @return [Time]
  def start
    @start ||= Time.zone.parse(@data[:gameDate])
  end

  # Return if the game time is to be determined.
  #
  # @return [Boolean]
  def tbd?
    @data.dig(:status, :detailedState) == TBD_STATE
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
      away:      { id: away.dig(:team, :id).to_s, score: away[:score] },
      home:      { id: home.dig(:team, :id).to_s, score: home[:score] },
      start:     start,
      complete:  complete?,
      networks:  networks,
      postponed: postponed?,
      tbd:       tbd?,
      uid:       id,
      utc:       { start: start.utc, end: start.utc + 3.hours }
    }
  end
end
