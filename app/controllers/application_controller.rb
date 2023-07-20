class ApplicationController < Sinatra::Base
    set :default_content_type, 'application/json'
  
    get '/' do
      { name: 'Hello World' }.to_json
    end
  
  end