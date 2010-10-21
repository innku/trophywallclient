module TrophyWall
  
  mattr_accessor :app_token
  
  def self.setup
    yield self
  end
  
  if defined?(Rails)
    require 'trophywall/railtie'
    require 'trophywall/client'
  end
  
end