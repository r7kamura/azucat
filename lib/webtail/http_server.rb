module WebTail
  class HTTPServer
    def self.run(args)
      ws_port   = args[:ws_port]
      http_port = args[:http_port]

      WebTail::HTTPApp.set :ws_port, ws_port

      ::Rack::Handler::WEBrick.run(
        WebTail::HTTPApp.new,
        :Port      => http_port,
        :AccessLog => [nil, nil],
        :Logger    => ::WEBrick::Log.new("/dev/null")
      )
    end
  end
end
