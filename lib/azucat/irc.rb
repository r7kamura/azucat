module Azucat
  module IRC
    require "azucat/irc/pattern"
    require "azucat/irc/client"
    require "azucat/irc/message"
    extend self

    def client
      @client ||= Client.new(Azucat.config.irc)
    end
  end

  init do
    next unless config.irc
    Notify.register config.irc.username
  end

  run do
    next unless config.irc
    begin
      IRC.client.on_message { |msg| Output.puts msg }
      IRC.client.start
    rescue SocketError => e
      Output.error(e)
    end
  end
end
