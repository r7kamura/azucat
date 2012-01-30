module Azucat
  class HTTPServer
    def self.run(args)
      ws_port   = args[:ws_port]
      http_port = args[:http_port]

      Azucat::HTTPApp.set :ws_port, ws_port

      ::Rack::Handler::WEBrick.run(
        Azucat::HTTPApp.new,
        :Port      => http_port,
        :AccessLog => [nil, nil],
        :Logger    => ::WEBrick::Log.new("/dev/null")
      )
    end
  end
end
