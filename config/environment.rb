ENV["RACK_ENV"] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV["RACK_ENV"])

require 'sinatra/activerecord/rake'
require 'faker'

require_all 'app'
