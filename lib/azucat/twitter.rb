module Azucat
  class Twitter

    Azucat.init do
      @config = {
        :host  => 'userstream.twitter.com',
        :path  => '/2/user.json',
        :ssl   => true,
        :oauth => {
          :access_key    => nil,
          :access_secret => nil,
          :proxy         => ENV["http_proxy"]
        }.merge(get_access_token(
          :consumer_key    => "B2tZeyZ96bB7BdQuk6r0A",
          :consumer_secret => "iA5pDiQpNaAjFw6FwWSwDUVFppU4dHVxicprAcPRak"
        ))
      }
    end

    def self.run(args)
      return unless args[:twitter]

      stream = ::Twitter::JSONStream.connect(@config)
      stream.each_item         { |item| Output.puts convert_to_str(item) }
      stream.on_error          { |msg|  Output.puts "Error: #{msg}"      }
      stream.on_reconnect      {        Output.puts "Reconnect"          }
      stream.on_max_reconnects {        Output.puts "Failed"             }
    rescue EventMachine::ConnectionError => e
      Output.puts("[ERROR] (#{self}) #{e.message}")
    end

    private
    def self.get_access_token(config)
      request_token = OAuth::Consumer.new(
        config[:consumer_key],
        config[:consumer_secret],
        :site  => "https://api.twitter.com",
        :proxy => ENV["http_proxy"]
      ).get_request_token

      puts "1) open: #{request_token.authorize_url}"
      ::Launchy.open(request_token.authorize_url) rescue nil

      puts "2) Enter the PIN"
      pin = STDIN.gets.strip

      access_token = request_token.get_access_token(:oauth_verifier => pin)
      config[:access_key]    = access_token.token
      config[:access_secret] = access_token.secret
      config
    end

    def self.convert_to_str(tweet_json)
      hash = JSON.parse(tweet_json)
      return unless hash["user"]

      user    = "%14.14s" % hash["user"]["screen_name"]
      user    = Output.random_colorize(user) + ":"
      command = "[TWIT]"
      text    = hash["text"]

      [user, command, text].join(" ")
    end
  end
end
