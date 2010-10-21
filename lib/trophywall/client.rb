require 'rest_client'
require 'ruby-debug'
require 'json/pure' unless {}.respond_to?(:to_json)

module TrophyWall
  class Client
  
    attr_reader :host, :token
  
    def initialize(token, host='localhost:3000')
      @token = token
      @host = host
      login
    end
    
    def login
      begin
        puts get('/start')
      rescue Errno::ECONNREFUSED
        puts 'TrophyWall: Connection could not be established'
      rescue RestClient::Unauthorized
        puts 'TrophyWall: Your token is invalid, actions will not be logged'
      end
    end
  
    def user_ladder
      JSON.parse(get('/users.json').body)
    end
  
    def hit(action, user, params={})
      post('/user_actions', {:user_action => {:action_name => action, 
                                              :user_params => {:id => user.id, 
                                                               :display_name => user.to_s},
                                              :created_at => params[:created_at] }})
    end
  
    def resource(uri)
       RestClient::Resource.new("http://#{host}", token, 'X')[uri]
    end

    def get(uri, extra_headers={})
      process(:get, uri, extra_headers  )
    end

    def post(uri, payload="", extra_headers={})
      process(:post, uri, extra_headers, payload)
    end

    def put(uri, payload, extra_headers={})
      process(:put, uri, extra_headers, payload)
    end

    def delete(uri, extra_headers={})
      process(:delete, uri, extra_headers)
    end

    def process(method, uri, extra_headers={}, payload=nil)
       headers  = extra_headers
       args     = [method, payload, headers].compact
       response = resource(uri).send(*args)
       response
    end
    
  end
end