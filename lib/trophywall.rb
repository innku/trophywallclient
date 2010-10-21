module TrophyWall
  
  mattr_accessor :app_token
  @@app_token = nil
  
  @@app = nil
  
  def self.setup
    yield self
    self.login 
  end
  
  def self.login
    @@app = TrophyWall::Client.new(@@app_token)
  end
  
  def self.app
    @@app
  end
  
  if defined?(Rails)
    require 'trophywall/client'
    require 'trophywall/railtie'
    require 'trophywall/challenge'
  end
  
end