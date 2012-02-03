class Azucat::HTTPServer
  def self.run(args)
    ::Rack::Handler::WEBrick.run(
      Azucat::HTTPApp.new { |app| app.settings.set :ws_port, args[:ws_port] },
      :Port      => args[:http_port],
      :Logger    => ::WEBrick::Log.new("/dev/null"),
      :AccessLog => [nil, nil]
    )
  end
end
