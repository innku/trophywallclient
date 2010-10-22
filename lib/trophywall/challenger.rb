module TrophyWall
  module Challenger
    def self.included(base)
      base.send :extend, ClassMethods
    end
    
    module ClassMethods
      
      def team(*team_names)
        teams(team_names)
      end
      
      def teams(*team_names)
        self.cattr_accessor :trophywall_teams
        self.trophywall_teams = team_names.flatten
      end
      
    end
    
  end
end