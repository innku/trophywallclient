module TrophyWall
  
  mattr_accessor :app_token
  @@app_token = nil
  
  @@app_token = nil
  
  def self.setup
    yield self
    self.login 
  end
  
  def self.login
    @app = TrophyWall::Client.new(@@app_token)
  end
  
  if defined?(Rails)
    require 'trophywall/client'
    require 'trophywall/railtie'
  end
  
end