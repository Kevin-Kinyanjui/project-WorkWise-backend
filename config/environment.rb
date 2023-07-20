ENV["RACK_ENV"] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV["RACK_ENV"])

require 'json'
require 'faker'
require 'sinatra'
require 'sinatra/flash'
require 'sinatra/activerecord/rake'

require_all 'app'
