module TrophyWall
  module Challenge
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :hit_on_create
    end
    
    module ClassMethods
      
      def hit_on_create
        after_create do |record|
          TrophyWall.app.hit(action_name(self.class), self.user)
        end
      end
            
    end
    
    def action_name(class_reference)
      "create-#{class_reference.name.downcase}"
    end
    
  end
end