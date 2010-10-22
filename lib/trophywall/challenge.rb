module TrophyWall
  module Challenge
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
      base.send :trophywall_hit_on_create
    end
    
    module ClassMethods
      
      def challenge(name)
        self.cattr_accessor :trophywall_challenge_name
        self.trophywall_challenge_name = name.to_s
      end
      
      def challenger(challenger_call)
        self.cattr_accessor :trophywall_challenger
        self.trophywall_challenger = challenger_call.to_s
      end
      
      def not_challenging_for_trophywall
        self.cattr_accessor :challenging_for_trophywall
        self.challenging_for_trophywall = false
      end
      
      def challenge_on(action, params={})
        challenge = params[:challenge] || "#{action}-#{formatted_class_name}"
        self.send "after_#{action}" do |record|
          if (block_given? && yield(record)) || !block_given?
            trophywall_hit(challenge, params[:challenger])
          end
        end
      end
            
      private
      
      def trophywall_hit_on_create
        after_create do |record|
          if challenging_for_trophywall?
            trophywall_hit(create_challenge_name_for_trophywall)
          end
        end
      end
      
    end
    
    module InstanceMethods
      
      def trophywall_hit(action, user=nil)
        user ||= trophywall_challenger
        teams = trophywall_challenger_teams_for(user)
        TrophyWall.app.hit(action, user.id, user.to_s, :teams => teams)
      end
      
      private
      
      def trophywall_challenger_teams_for(user)
        if user.class.respond_to? :trophywall_teams
          user.class.send(:trophywall_teams).collect do |team_name|
            team = user.send(team_name)
            trophywall_formatted_team_name(team)
          end
        end
      end
      
      def trophywall_formatted_team_name(team)
        if team.is_a?(String)
          {:display_name => team}
        else
          {:id => team.id, :display_name => team.to_s}
        end
      end
      
      def trophywall_challenger
        if self.class.respond_to? :trophywall_challenger
          self.send self.class.trophywall_challenger
        else
          self.send :user
        end
      end
      
      def create_challenge_name_for_trophywall
        if self.class.respond_to? :trophywall_challenge_name
          self.class.trophywall_challenge_name
        else
          trophywall_action_name('create')
        end
      end

      def trophywall_action_name(action)
        "#{action}-#{trophywall_formatted_class_name}"
      end
      
      def trophywall_formatted_class_name
        self.class.name.tableize.dasherize
      end
      
      def challenging_for_trophywall?
        if self.class.respond_to? :challenging_for_trophywall
          self.class.challenging_for_trophywall
        else
          true
        end
      end
      
    end
    
  end
end