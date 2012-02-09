module Azucat
  module HTTPServer
    extend self

    def run
      ::Rack::Handler::WEBrick.run(
        Class.new(Sinatra::Base) {
          set :root, File.expand_path("../../../", __FILE__)
          set :ws_port, Azucat.config.ws_port

          get "/" do
            @ws_port = settings.ws_port
            erb :index
          end

          post "/" do
            tweet(params[:command])
          end
        },
        :Port      => Azucat.config.http_port,
        :Logger    => ::WEBrick::Log.new("/dev/null"),
        :AccessLog => [nil, nil]
      )
    end

    private
    def tweet(str)
      Twitter.tweet(params[:command])
    end
  end
end
