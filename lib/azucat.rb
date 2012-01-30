require "socket"

gemfile = File.expand_path('../../Gemfile', __FILE__)
begin
  ENV["BUNDLE_GEMFILE"] = gemfile
  require "rubygems"
  require "bundler"
  Bundler.require
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)

require "azucat/ext"
require "azucat/http_server"
require "azucat/http_app"
require "azucat/websocket_server"
require "azucat/output"

Thread.abort_on_exception = true

module Azucat
  extend self

  def start(opts = {})
    opts = {
      :log_size     => 100,
      :ws_port      => unused_port,
      :http_port    => unused_port,
      :open_browser => true
    }.merge(opts)

    logs = []
    channel = EM::Channel.new
    channel.subscribe do |msg|
      logs << msg
      logs.shift if logs.size > opts[:log_size]
    end

    EM.run do
      EM.defer { Azucat::Output.run(channel) }
      EM.defer { Azucat::WebSocketServer.run(
        :channel => channel,
        :logs    => logs,
        :port    => opts[:ws_port]) }
      EM.defer { Azucat::HTTPServer.run(
        :ws_port   => opts[:ws_port],
        :http_port => opts[:http_port]) }

      if opts[:open_browser]
        EM.defer {
          sleep 1
          ::Launchy.open("http://localhost:#{opts[:http_port]}")
        }
      end
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
