require "socket"
require "kconv"
require "logger"

begin
  ENV["BUNDLE_GEMFILE"] = File.expand_path('../../Gemfile', __FILE__)
  require "rubygems"
  require "bundler"
  Bundler.require(:default, :development)
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`"
  exit!
end

module Azucat
  require "azucat/core"
  extend Core

  require "azucat/ext"
  require "azucat/http_server"
  require "azucat/websocket_server"
  require "azucat/input"
  require "azucat/output"
  require "azucat/twitter"
  require "azucat/irc"
  require "azucat/skype"
  require "azucat/manager"
end
