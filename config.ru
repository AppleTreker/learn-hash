require 'rubygems'
require 'bundler'

Bundler.require

require './app.rb'

require './bar_builder.rb'

# Routes
require './routes.rb'

# Helpers
Dir['./helpers/*.rb'].each { |file| require file }

require './bar_config.rb'

run Template
