require File.expand_path("../../../spec_helper", File.dirname(__FILE__))

describe Azucat::IRC::Client do
  before do
    @self     = Azucat::IRC::Client
    @self.stub(:connect)
    @self.stub(:login)
    @client   = @self.new
    @commands = %w[
      ADMIN   KICK    MOTD     QUIT     VERSION
      AWAY    KNOCK   NAMES    RULES    VHOST
      CREDITS LICENSE NICK     SETNAME  WATCH
      CYCLE   LINKS   NOTICE   SILENCE  WHO
      DALINFO LIST    PART     STATS    WHOIS
      INVITE  LUSERS  PING     TIME     WHOWAS
      ISON    MAP     PONG     TOPIC    USER
      JOIN    MODE    PASS     USERHOST
    ]
  end
end
