module TrophyWall
  module Challenger
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :define_class_variable
    end
    
    module ClassMethods
      
      def define_class_variable
        self.cattr_accessor :trophywall_teams
        self.trophywall_teams = {}
      end
      
      def team(calling_name, params={})
        team_category = params[:name] || calling_name
        self.trophywall_teams[team_category] = {}
        self.trophywall_teams[team_category][:name] = calling_name.to_s
        self.trophywall_teams[team_category][:id] = params[:id] || 'id'
        self.trophywall_teams[team_category][:display] = params[:display] || 'to_s'
      end
      
    end
    
  end
end