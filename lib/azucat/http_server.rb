module Azucat
  module HTTPServer
    extend self

    def run
      ::Rack::Handler.default.run(
        Class.new(Sinatra::Base) {
          set :root, File.expand_path("../../../", __FILE__)
          set :ws_port, Azucat.config.ws_port

          get "/" do
            @ws_port = settings.ws_port
            erb :index
          end

          post "/" do
            Command.input(params[:command])
          end
        },
        :Port          => Azucat.config.http_port,
        :Logger        => ::WEBrick::Log.new("/dev/null"),
        :AccessLog     => [nil, nil],
        :StartCallback => proc { open_browser }
      )
    end

    private

    def open_browser
      return unless Azucat.config.open_browser
      http_host   = Azucat.config.http_host
      http_port   = Azucat.config.http_port
      ::Launchy.open("http://#{http_host}:#{http_port}") rescue nil
    end
  end
end
