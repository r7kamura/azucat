require "socket"
require "rubygems"
require "bundler"
Bundler.require

require "webtail/ext"
require "webtail/http_server"
require "webtail/websocket_server"
require "webtail/output"

Thread.abort_on_exception = true

module WebTail
  extend self

  def start(opts = {})
    opts = {
      :log_size     => 100,
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
      EM.defer { WebTail::Output.run(channel) }
      EM.defer { WebTail::WebSocketServer.run(:channel => channel, :logs => logs) }
      EM.defer { WebTail::HTTPServer.run(:port => opts[:http_port]) }

      if opts[:open_browser]
        EM.defer {
          sleep 1; ::Launchy.open("http://localhost:#{opts[:http_port]}")
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
