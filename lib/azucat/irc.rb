module Azucat::IRC
  require "azucat/irc/pattern"
  require "azucat/irc/client"
  require "azucat/irc/message"

  extend self

  Azucat.init do |opts|
    next unless Azucat.config.irc
    Azucat::Output.notify do |filtered|
      filtered.match(config.irc.username)
    end
  end

  def run
    return unless Azucat.config.irc

    client = Client.new(Azucat.config.irc)
    client.on_message do |msg|
      Azucat::Output.puts msg
    end
    client.start
  end
end
