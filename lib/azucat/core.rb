module Azucat
  module Core
    def init(opts = {}, &block)
      @inits ||= []
      block ?
        @inits << block :
        @inits.each { |proc| proc.call(opts) }
    end

    def start(opts = {})
      # exit to press Ctrl+D
      trap('INT') { exit! }

      init(opts)
      opts = {
        :log_size     => 100,
        :ws_port      => unused_port,
        :ws_host      => "localhost",
        :http_port    => unused_port,
        :http_host    => "localhost",
        :open_browser => true,
        :channel      => EM::Channel.new
      }.merge(opts)

      Output.channel = opts[:channel]
      Thread.abort_on_exception = true
      EM.run do
        # basic
        EM.defer { HTTPServer.run(opts)      }
        EM.defer { WebSocketServer.run(opts) }
        EM.defer { Input.run(opts)           }
        EM.defer { Browser.open(opts)        }

        # optional
        EM.defer { Twitter.run(opts)         }
        EM.defer { IRC.run(opts)             }
        EM.defer { Skype.run(opts)           }
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
end
