# frozen_string_literal: true

module Jekyll
  module Filters
    module Logo
      TEAM_ID_TO_EMOJI = {
        1  => "&#128127;",          # Devils
        2  => "&#127965;",          # Islanders
        3  => "&#128509;",          # Rangers
        4  => "&#129472;",          # Flyers
        5  => "&#128039;",          # Penguins
        6  => "&#128059;",          # Bruins
        7  => "&#128481;",          # Sabres
        8  => "&#127464;&#127462;", # Canadiens
        9  => "&#9878;&#65039;",    # Senators
        10 => "&#127809;",          # Maple Leafs
        12 => "&#127786;",          # Hurricanes
        13 => "&#128006;",          # Panthers
        14 => "&#9889;&#65039;",    # Lightning
        15 => "&#127963;",          # Capitals
        16 => "&#129413;",          # Blackhawks
        17 => "&#128030;",          # Red Wings
        18 => "&#127928;",          # Predators
        19 => "&#127926;",          # Blues
        20 => "&#128293;",          # Flames
        21 => "&#127956;",          # Avalanche
        22 => "&#128738;",          # Oilers
        23 => "&#128011;",          # Canucks
        24 => "&#129414;",          # Ducks
        25 => "&#10024;",           # Stars
        26 => "&#128081;",          # Kings
        28 => "&#129416;",          # Sharks
        29 => "&#128085;",          # Blue Jackets
        30 => "&#129420;",          # Wild
        52 => "&#9992;&#65039;",    # Jets
        53 => "&#128058;",          # Coyotes
        54 => "&#127894;",          # Golden Knights
        55 => "&#128025;"           # Kraken
      }.freeze

      # Convert a team ID to an emoji.
      #
      # @param [String] id The team ID.
      # @return [String] The team emoji.
      def team_id_to_emoji(id)
        TEAM_ID_TO_EMOJI[id.to_i]
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::Filters::Logo)
