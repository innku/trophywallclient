module TrophyWall
  module Challenge
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
      base.send :trophywall_hit_on_create
    end
    
    module ClassMethods
      
      def challenge_name(name)
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
            
      private
      
      def trophywall_hit_on_create
        after_create do |record|
          if challenging_for_trophywall?
            trophywall_hit(create_challenge_name)
          end
        end
      end
      
    end
    
    module InstanceMethods
      
      def trophywall_hit(action, user=nil)
        TrophyWall.app.hit(action, challenger)
      end
      
      private
      
      def challenger
        if self.class.respond_to? :trophywall_challenger
          self.send self.class.trophywall_challenger
        else
          self.send :user
        end
      end
      
      def create_challenge_name
        if self.class.respond_to? :trophywall_challenge_name
          self.class.trophywall_challenge_name
        else
          trophywall_action_name('create')
        end
      end

      def trophywall_action_name(action)
        "#{action}-#{self.class.name.downcase}"
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