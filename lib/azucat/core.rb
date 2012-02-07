module Azucat
  module Core
    attr_accessor :config

    def start(opts = {})
      configure(opts)
      init

      trap('INT') { exit! }
      Thread.abort_on_exception = true
      EM.run do
        # basic
        EM.defer { HTTPServer.run      }
        EM.defer { WebSocketServer.run }
        EM.defer { Input.run           }
        EM.defer { Browser.run         }

        # optional
        EM.defer { Twitter.run         }
        EM.defer { IRC.run             }
        EM.defer { Skype.run           }
      end
    end

    def configure(opts)
      @config = Hashie::Mash.new(
        :file         => File.expand_path("~/.azucat"),
        :log_size     => 100,
        :ws_port      => unused_port,
        :ws_host      => "localhost",
        :http_port    => unused_port,
        :http_host    => "localhost",
        :open_browser => true,
        :channel      => EM::Channel.new,
        :consumer_key    => "B2tZeyZ96bB7BdQuk6r0A",
        :consumer_secret => "iA5pDiQpNaAjFw6FwWSwDUVFppU4dHVxicprAcPRak"
      ).merge(opts)
      load_or_create_config_file
    end

    def init(&block)
      @inits ||= []
      block ? @inits << block : @inits.each(&:call)
    end

    private
    def unused_port
      s = ::TCPServer.open(0)
      port = s.addr[1]
      s.close
      port
    end

    def load_or_create_config_file
      file = config[:file]
      File.exists?(file) ? load(file) : File.open(file, "w")
    end
  end
end
