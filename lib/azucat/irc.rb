module Azucat::IRC
  require "azucat/irc/pattern"
  require "azucat/irc/client"
  require "azucat/irc/message"

  extend self
  def run(args)
    return unless args[:irc]

    Client.new(args[:irc])
      .on_message { |msg| Azucat::Output.puts msg }
      .start
  end
end
