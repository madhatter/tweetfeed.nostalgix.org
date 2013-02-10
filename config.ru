require 'rubygems'
require 'bundler'

Bundler.require

require './tweetfeed'
run Sinatra::Application
