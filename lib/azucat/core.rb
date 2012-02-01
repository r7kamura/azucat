module Azucat
  module Core
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
        EM.defer { Input.run(opts)           }
        EM.defer { Browser.open(opts)        }
        EM.defer { Twitter.run(opts)         }
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

  extend Core
end
