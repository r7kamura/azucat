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
      @is_connected = false

      connect
      login
    end

    %w[
      ADMIN   KICK    MOTD     QUIT     VERSION
      AWAY    KNOCK   NAMES    RULES    VHOST
      CREDITS LICENSE NICK     SETNAME  WATCH
      CYCLE   LINKS   NOTICE   SILENCE  WHO
      DALINFO LIST    PART     STATS    WHOIS
      INVITE  LUSERS  PING     TIME     WHOWAS
      ISON    MAP     PONG     TOPIC    USER
      JOIN    MODE    PASS     USERHOST
    ].each do |name|
      define_method(name.downcase) do |*params|
        command [name, params].flatten.join(" ")
      end
    end

    def on_message(*args, &block)
      block ?
        @on_message = block :
        @on_message.call(*args)
    end

    def start(&block)
      while str = @socket.gets
        on_receive(str)
      end
    end

    private

    def on_receive(str)
      msg = Message.parse(str)
      case msg.command
      when "PING"
        pong(str)
      when *%w[JOIN KICK MODE NOTICE TOPIC PRIVMSG]
        on_message(msg)
      end
    end

    def connect
      @socket = TCPSocket.new(@server, @port)
    end

    def command(msg)
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
