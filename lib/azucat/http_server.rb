module Azucat
  module HTTPServer
    extend self

    class App < ::Sinatra::Base
      set :root,       File.expand_path("../../../", __FILE__)
      set :ws_port,    Azucat.config.ws_port
      set :audio,      Azucat.config.audio
      set :audio_path, Azucat.config.audio_path

      get "/" do
        @ws_port    = settings.ws_port
        @audio      = settings.audio
        @audio_path = settings.audio_path
        erb :index
      end

      post "/" do
        Command.input(params[:command]) if params[:command]
      end
    end

    def open_browser
      return unless Azucat.config.open_browser
      http_host   = Azucat.config.http_host
      http_port   = Azucat.config.http_port
      ::Launchy.open("http://#{http_host}:#{http_port}") rescue nil
    end
  end

  run do
    ::Rack::Handler::WEBrick.run(HTTPServer::App.new,
      :Port          => config.http_port,
      :Logger        => ::WEBrick::Log.new("/dev/null"),
      :AccessLog     => [nil, nil],
      :StartCallback => proc { HTTPServer.open_browser }
    )
  end
end
