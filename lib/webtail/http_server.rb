module WebTail
  class HTTPServer
    def self.run(args)
      port = args[:port]

      html = File.read(File.expand_path("../../../views/index.html", __FILE__))
      ::Rack::Handler::WEBrick.run(
        proc { [200, {"Content-Type" => "text/html; charset=UTF-8"}, html] },
        :Port      => port,
        :AccessLog => [nil, nil],
        :Logger    => ::WEBrick::Log.new("/dev/null")
      )
    end
  end
end
