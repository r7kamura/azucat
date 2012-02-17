module Azucat
  module IRC
    require "azucat/irc/pattern"
    require "azucat/irc/client"
    require "azucat/irc/message"
    extend self

    def start
      @client = IRC::Client.new(Azucat.config.irc)
      @client.on_message { |msg| Output.puts msg }
      @client.start
    rescue SocketError => e
      Output.error(e)
    end
  end

  init { config.irc and Notify.register(config.irc.username) }
  run  { config.irc and IRC.start }
end
