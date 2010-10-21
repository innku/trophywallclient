require 'trophywall'
require 'rails'
  
module TrophyWall
  class Railtie < Rails::Railtie
        
    initializer "railtie.configure_rails_initialization" do
      puts 'hello'
    end
    
  end
end