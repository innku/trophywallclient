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
  
    def hit(action, user_id, user_display_name, params={})
      post('/user_actions', {:user_action => {:challenge =>   {:name => action}, 
                                              :challenger =>  {:id => user_id, 
                                                               :name => user_display_name,
                                                               :teams => params[:teams]},
                                              :created_at =>  params[:timestamp] }})
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