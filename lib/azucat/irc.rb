module Azucat::IRC
  require "azucat/irc/pattern"
  require "azucat/irc/client"
  require "azucat/irc/message"

  extend self
  def run
    client = Client.new(
      :server   => "irc.freenode.net",
      :port     => 6667,
      :channel  => "#test-r",
      :username => "rrrrrrrrrr-uby",
    )

    client.on_message { |msg| Azucat::Output.puts msg }
    client.start
  end
end
