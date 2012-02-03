module Azucat::IRC
  require "azucat/irc/pattern"
  require "azucat/irc/client"
  require "azucat/irc/message"

  extend self
  def run(args)
    return unless args[:irc]

    client = Client.new(args[:irc])
    client.on_message { |msg| Azucat::Output.puts msg }
    client.start
  end
end
