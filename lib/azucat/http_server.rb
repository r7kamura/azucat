class Azucat::HTTPServer
  def self.run(args)
    ::Rack::Handler::WEBrick.run(
      Class.new(Sinatra::Base) {
        set :root, File.expand_path("../../../", __FILE__)
        set :ws_port, args[:ws_port]

        get "/" do
          @ws_port = settings.ws_port
          erb :index
        end
      },
      :Port      => args[:http_port],
      :Logger    => ::WEBrick::Log.new("/dev/null"),
      :AccessLog => [nil, nil]
    )
  end
end
