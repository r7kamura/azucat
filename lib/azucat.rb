require "socket"

begin
  ENV["BUNDLE_GEMFILE"] = File.expand_path('../../Gemfile', __FILE__)
  require "rubygems"
  require "bundler"
  Bundler.require
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`"
  exit!
end

require "azucat/ext"
require "azucat/core"
require "azucat/http_server"
require "azucat/http_app"
require "azucat/websocket_server"
require "azucat/input"
require "azucat/output"
require "azucat/browser"
require "azucat/twitter"
