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
      
      def timestamp(timestamp_call)
        self.cattr_accessor :trophywall_timestamp
        self.trophywall_timestamp = timestamp_call.to_sym
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
        if user.is_a?(ActiveRecord::Base) and !user.new_record? #TODO => Allow not only ActiveRecord
          TrophyWall.app.hit(action, user.id, user.to_s, :teams => challenger_teams_for(user),
                                                         :class => user.class.to_s,
                                                         :timestamp => call_trophywall_timestamp)
        end
      end
      
      private
      
      def challenger_teams_for(user)
        if user.class.respond_to? :trophywall_teams
          user.get_trophywall_teams
        end
      end
      
      def trophywall_challenger
        if self.class.respond_to? :trophywall_challenger
          self.send self.cl<ass.trophywall_challenger
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
      
      def call_trophywall_timestamp
        if self.class.respond_to? :trophywall_timestamp
          self.send(self.class.send(:trophywall_timestamp))
        end
      end
      
    end
    
  end
end