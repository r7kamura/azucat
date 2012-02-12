module Azucat
  module Twitter
    extend self

    Azucat.init do
      next unless Azucat.config.twitter
      setup_config
      begin
        setup_client_and_info
      rescue SocketError
        Azucat.config.twitter = false
        next
      end

      Notify.register(?@ + @info["screen_name"])
      Command.register(/^tweet (.+)/) { |m| tweet(m[1]) }
    end


    def run
      return unless Azucat.config.twitter
      recent
      start_stream
    end

    def tweet(str)
      @client.update(str)
    end

    def recent
      @client.home_timeline.reverse_each do |tweet|
        Output.puts parse_tweet(tweet)
      end
    end

    private

    def setup_config
      config = Azucat.config
      get_access_token unless config.access_key and config.access_secret

      @config = {
        :host  => 'userstream.twitter.com',
        :path  => '/2/user.json',
        :ssl   => true,
        :oauth => {
          :access_key      => nil,
          :access_secret   => nil,
          :proxy           => ENV["http_proxy"],
          :consumer_key    => config.consumer_key,
          :consumer_secret => config.consumer_secret,
          :access_key      => config.access_key,
          :access_secret   => config.access_secret
        }
      }
    end

    def setup_client_and_info
      @client = ::TwitterOAuth::Client.new(
        :consumer_key    => @config[:oauth][:consumer_key],
        :consumer_secret => @config[:oauth][:consumer_secret],
        :token           => @config[:oauth][:access_key],
        :secret          => @config[:oauth][:access_secret]
      )
      @info = @client.info
    end

    def start_stream
      stream = ::Twitter::JSONStream.connect(@config)
      stream.each_item         { |item| Output.puts parse_tweet(item)    }
      stream.on_error          { |msg|  Output.puts "Error: #{msg}"      }
      stream.on_reconnect      {        Output.puts "Reconnect"          }
      stream.on_max_reconnects {        Output.puts "Failed"             }
    rescue EventMachine::ConnectionError => e
      Output.puts("[ERROR] (#{self}) #{e.message}")
    end

    def get_access_token
      please_open_authorize_url
      please_enter_the_pin
      get_and_save_access_token
    end

    def please_open_authorize_url
      puts "1) Open: #{request_token.authorize_url}"
      ::Launchy.open(request_token.authorize_url) rescue nil
    end

    def please_enter_the_pin
      print "2) Enter the PIN > "
      @pin = STDIN.gets.strip
    end

    def get_and_save_access_token
      Azucat.config[:access_key]    = access_token.token
      Azucat.config[:access_secret] = access_token.secret
      write_config
    end

    def request_token
      @request_token ||= OAuth::Consumer.new(
        Azucat.config[:consumer_key],
        Azucat.config[:consumer_secret],
        :site  => "https://api.twitter.com",
        :proxy => ENV["http_proxy"],
        :ssl   => true
      ).get_request_token
    end

    def access_token
      @access_token ||= request_token.get_access_token(:oauth_verifier => @pin)
    end

    def write_config
      puts "Saving token and secret to #{Azucat.config[:file]}"
      File.open(Azucat.config[:file], "a") do |f|
        f.puts %{Azucat.config[:access_key]    = '#{Azucat.config[:access_key]}'}
        f.puts %{Azucat.config[:access_secret] = '#{Azucat.config[:access_secret]}'}
      end
    end

    def parse_tweet(tweet)
      tweet = JSON.parse(tweet) if tweet.class == String
      return unless tweet["user"]
      {
        :name => tweet["user"]["screen_name"],
        :text => tweet["text"],
        :tag  => "TWIT"
      }
    end
  end
end
