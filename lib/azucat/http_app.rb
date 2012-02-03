class Azucat::HTTPApp < Sinatra::Base
  set :root, File.expand_path("../../../", __FILE__)

  get "/" do
    @ws_port = settings.ws_port
    erb :index
  end
end
