module Azucat
  class Twitter

    Azucat.init do
      next unless Azucat.config.twitter

      if Azucat.config.access_key.blank? || Azucat.config.access_secret.blank?
        get_access_token
      end
      @config = {
        :host  => 'userstream.twitter.com',
        :path  => '/2/user.json',
        :ssl   => true,
        :oauth => {
          :access_key      => nil,
          :access_secret   => nil,
          :proxy           => ENV["http_proxy"],
          :consumer_key    => Azucat.config.consumer_key,
          :consumer_secret => Azucat.config.consumer_secret,
          :access_key      => Azucat.config.access_key,
          :access_secret   => Azucat.config.access_secret
        }
      }

      @screen_name = ::TwitterOAuth::Client.new(
        :consumer_key    => @config[:oauth][:consumer_key],
        :consumer_secret => @config[:oauth][:consumer_secret],
        :token           => @config[:oauth][:access_key],
        :secret          => @config[:oauth][:access_secret]
      ).info["screen_name"]

      Azucat::Output.notify do |filtered|
        filtered.match("@" + @screen_name)
      end
    end

    def self.run
      return unless Azucat.config.twitter

      stream = ::Twitter::JSONStream.connect(@config)
      stream.each_item         { |item| Output.puts convert_to_str(item) }
      stream.on_error          { |msg|  Output.puts "Error: #{msg}"      }
      stream.on_reconnect      {        Output.puts "Reconnect"          }
      stream.on_max_reconnects {        Output.puts "Failed"             }
    rescue EventMachine::ConnectionError => e
      Output.puts("[ERROR] (#{self}) #{e.message}")
    end

    private
    def self.get_access_token
      request_token = OAuth::Consumer.new(
        Azucat.config[:consumer_key],
        Azucat.config[:consumer_secret],
        :site  => "https://api.twitter.com",
        :proxy => ENV["http_proxy"],
        :ssl   => true
      ).get_request_token

      puts "1) open: #{request_token.authorize_url}"
      ::Launchy.open(request_token.authorize_url) rescue nil

      puts "2) Enter the PIN"
      pin = STDIN.gets.strip

      access_token = request_token.get_access_token(:oauth_verifier => pin)
      config = Azucat.config
      config[:access_key]    = access_token.token
      config[:access_secret] = access_token.secret
      puts %{Saving 'token' and 'secret' to '#{config[:file]}'}
      File.open(Azucat.config[:file], "a") do |f|
        f.puts %{Azucat.config[:access_key]    = '#{config[:access_key]}'}
        f.puts %{Azucat.config[:access_secret] = '#{config[:access_secret]}'}
      end
      access_token
    end

    def self.convert_to_str(tweet_json)
      hash = JSON.parse(tweet_json)
      return unless hash["user"]

      Azucat::Output.stringify(
        :name => hash["user"]["screen_name"],
        :tag  => "TWIT",
        :text => hash["text"]
      )
    end
  end
end
