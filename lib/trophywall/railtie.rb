require 'trophywall'
require 'rails'
  
module TrophyWall
  class TrophyWallRailtie < Rails::RailTie
    railtie_name :trophywall
    
    initializer "trophy_wall_railtie.configure_rails_initialization" do
      puts 'hello'
    end
    
  end
end