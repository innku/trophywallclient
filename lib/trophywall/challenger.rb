module TrophyWall
  module Challenger
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
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
        self.trophywall_teams[team_category][:calling_name] = calling_name.to_s
        self.trophywall_teams[team_category][:id] = (params[:id].nil? ? 'id' : params[:id].to_s)
        self.trophywall_teams[team_category][:display] = (params[:display].nil? ? 'to_s' : params[:display].to_s)
      end
      
    end
    
    module InstanceMethods
      
      protected
       
      def get_trophywall_teams
        teams = {}
        team_specs = self.class.send(:trophywall_teams)
        team_specs.keys.each do |team_calling|
          teams[team_calling] = trophywall_formatted_team_name(trophywall_team(team_calling),
                                                                team_specs[team_calling])
          teams.delete(team_calling) if teams[team_calling].nil?
        end
        teams
      end
      
      def trophywall_formatted_team_name(team, team_hash)
        unless team.nil?
          { :id => trophywall_team_id(team, team_hash[:id]), 
            :name => trophywall_team_name(team, team_hash[:display]).to_s }
        end
      end
      
      def trophywall_team_name(team, display_call)
        unless display_call.blank?
          if team.respond_to?(display_call) and !team.send(display_call).nil?
            return team.send display_call
          end
        end
        team.to_s
      end
      
      def trophywall_team_id(team, id_call)
        unless id_call.blank?
          if team.is_a?(ActiveRecord::Base) and !team.new_record? #TODO => Refactor for not only active record
            team.send id_call
          end
        end
      end
      
      def trophywall_team(team_calling)
        if self.respond_to? team_calling
          self.send team_calling
        end
      end
      
      def trophywall_attribute(att)
        if self.respond_to? att.to_s
          attribute = self.send att
        end
      end
      
    end
    
  end
end