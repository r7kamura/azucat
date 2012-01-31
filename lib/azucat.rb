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
require "azucat/http_server"
require "azucat/http_app"
require "azucat/websocket_server"
require "azucat/output"
require "azucat/browser"

module Azucat
  extend self

  def start(opts = {})
    opts = {
      :log_size     => 100,
      :ws_port      => unused_port,
      :ws_host      => "localhost",
      :http_port    => unused_port,
      :http_host    => "localhost",
      :open_browser => true,
      :channel      => EM::Channel.new
    }.merge(opts)

    Thread.abort_on_exception = true
    EM.run do
      EM.defer { HTTPServer.run(opts)      }
      EM.defer { WebSocketServer.run(opts) }
      EM.defer { Output.run(opts)          }
      EM.defer { Browser.open(opts)        }
    end
  end

  private
  def unused_port
    s = ::TCPServer.open(0)
    port = s.addr[1]
    s.close
    port
  end
end
