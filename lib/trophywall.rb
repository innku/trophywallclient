module TrophyWall
  
  mattr_accessor :app_token
  
  def self.setup
    yield self
  end
  
  if defined?(Rails)
    require 'trophywall/client'
    require 'trophywall/railtie'
  end
  
end