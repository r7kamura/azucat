$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "azucat"
Bundler.require(:default, :development, :test)

RSpec.configure do |c|
  c.before do
    Azucat.stub(:load_or_create_config) do
      Azucat.config = {}
      Azucat.config.merge!(
        :root            => File.expand_path("../../", __FILE__),
        :file            => File.expand_path("~/.azucat"),
        :log_size        => 100,
        :ws_port         => unused_port,
        :ws_host         => "localhost",
        :http_port       => unused_port,
        :http_host       => "localhost",
        :open_browser    => true,
        :channel         => EM::Channel.new,
        :consumer_key    => "B2tZeyZ96bB7BdQuk6r0A",
        :consumer_secret => "iA5pDiQpNaAjFw6FwWSwDUVFppU4dHVxicprAcPRak",
        :skype           => true,
        :twitter         => true,
        :irc             => {
          :server   => "irc.freenode.net",
          :port     => 6667,
          :channel  => "#azucat",
          :username => "azucat",
        },
      )
    end
  end
end
