module TrophyWall
  
  mattr_accessor :app_token
  @@app_token = nil
  
  mattr_accessor :user_class
  @@user_class = 'User'
  
  mattr_accessor :log_everything
  @@log_everything = false
  
  @@app = nil
  
  def self.setup
    yield self
    
    self.login 
    
    ActiveRecord::Base.send :include, TrophyWall::Challenge if @@log_everything
    
  end
  
  def self.login
    @@app = TrophyWall::Client.new(@@app_token)
  end
  
  def self.app
    @@app
  end
  
  def self.call_user
    self.user_class.downcase
  end
  
  if defined?(Rails)
    require 'trophywall/client'
    require 'trophywall/railtie'
    require 'trophywall/challenge'
  end
  
end