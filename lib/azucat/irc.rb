module Azucat::IRC
  require "azucat/irc/pattern"
  require "azucat/irc/client"
  require "azucat/irc/message"

  extend self

  Azucat.init do |opts|
    next unless opts[:irc]
    Azucat::Output.notify do |filtered|
      filtered.match(opts[:irc][:username])
    end
  end

  def run(args)
    return unless args[:irc]

    client = Client.new(args[:irc])
    client.on_message do |msg|
      Azucat::Output.puts msg
    end
    client.start
  end
end
