module Azucat
  init do
    next unless config.irc
    Notify.register config.irc.username
  end

  module IRC
    require "azucat/irc/pattern"
    require "azucat/irc/client"
    require "azucat/irc/message"
    extend self

    def client
      @client ||= Client.new(Azucat.config.irc)
    end

    def run
      return unless Azucat.config.irc
      @client.on_message { |msg| Output.puts msg.to_hash }
      @client.start
    rescue SocketError => e
      Output.error(e)
    end
  end
end
