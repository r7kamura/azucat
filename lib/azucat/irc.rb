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

    def run
      return unless Azucat.config.irc
      client = Client.new(Azucat.config.irc)
      client.on_message { |msg| Output.puts msg.to_hash }
      client.start
    end
  end
end
