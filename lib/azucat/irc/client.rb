module Azucat::IRC
  class Client
    def initialize(attr)
      @server       = attr[:server]
      @port         = attr[:port]
      @username     = attr[:username]
      @nickname     = attr[:nickname] || @username
      @realname     = attr[:realname] || @username
      @channel      = attr[:channel]
      @password     = attr[:password]
      @eol          = attr[:eol] || "\r\n"
      @logger       = attr[:logger] || ::Logger.new(STDOUT)
      @logger.level = ::Logger::DEBUG
      @is_connected = false

      connect
      login
    end

    %w[
      ADMIN   KICK    MOTD    QUIT     VERSION
      AWAY    KNOCK   NAMES   RULES    VHOST
      CREDITS LICENSE NICK    SETNAME  WATCH
      CYCLE   LINKS   NOTICE  SILENCE  WHO
      DALINFO LIST    PART    STATS    WHOIS
      INVITE  LUSERS  PING    TIME     WHOWAS
      ISON    MAP     PONG    TOPIC    PASS
      JOIN    MODE    USERHOST USER
    ].each do |name|
      define_method(name.downcase) do |*params|
        command [name, params].flatten.join(" ")
      end
    end

    def on_message(*args, &block)
      block ?
        @on_message = block :
        @on_message.call(*args)
      self
    end

    def start(&block)
      while msg = @socket.gets
        on_message(Message.parse(msg))
        pong if msg.split(" ")[0] == "PING"
      end
    end

    private

    def connect
      @socket = TCPSocket.new(@server, @port)
    end

    def command(msg)
      @logger.debug("[#{Time.now}] Command: #{msg}")
      @socket.write(msg + @eol)
    end

    def privmsg(msg)
      command ["PRIVMSG", @channel, ":" + msg].join(" ")
    end

    def login
      pass @password if @password
      nick @nickname
      user @username, 0, "*", ":" + @realname
      join @channel if @channel
    end
  end
end
