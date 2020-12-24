# frozen_string_literal: true

class Game
  COMPLETE_STATE  = "Final"
  MAXIMUM_TEAM_ID = 100
  POSTPONED_STATE = "Postponed"
  TBD_STATE = "Scheduled (Time TBD)"

  def initialize(data)
    @data = data.deep_symbolize_keys.slice(:gameDate, :gamePk, :teams, :status)
  end

  # Extract the away team data.
  #
  # @return [Hash]
  def away
    @away ||= @data.dig(:teams, :away)
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
    @date ||= time.to_date
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
    @start ||= begin
      time = Time.zone.parse(@data[:gameDate])
      time = time.to_date.in_time_zone("UTC") if tbd?
      time
    end
  end

  # Return if the game time is to be determined.
  #
  # @return [Boolean]
  def tbd?
    @data.dig(:status, :detailedState) == TBD_STATE
  end

  # Return the start time in the Eastern time zone.
  #
  # @return [Time]
  def time
    @time ||= start.in_time_zone(Time.zone)
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
      postponed: postponed?,
      tbd:       tbd?,
      time:      time,
      uid:       id
    }
  end
end
