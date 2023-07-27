require_relative "./config/environment"

use Rack::JSONBodyParser

use Rack::Cors do
    allow do
      origins 'http://localhost:3000'
      resource '*', headers: :any, methods: [:get, :post, :delete, :put, :patch, :options, :head]
    end
end

run ApplicationController