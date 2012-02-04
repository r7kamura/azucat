# WEBrick compatible for Ruby1.9
class String
  alias_method :each, :lines
end

module TwitterOAuth
  class Client
    private
    def consumer
      @consumer ||= OAuth::Consumer.new(
        @consumer_key,
        @consumer_secret,
        { :site => 'https://api.twitter.com', :proxy => @proxy }
      )
    end
  end
end
