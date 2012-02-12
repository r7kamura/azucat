module Azucat::IRC
  class Message
    attr_reader :prefix, :command, :params

    class InvalidMessage < StandardError; end
    def self.parse(str)
      all, prefix, command, *rest = Pattern::MESSAGE_PATTERN.match(str).to_a
      raise InvalidMessage unless all

      params = [].tap do |params|
        case
        when !rest[0].blank?
          middle, trailer, = *rest
        when !rest[2].blank?
          middle, trailer, = *rest[2, 2]
        when rest[1]
          params  = []
          trailer = rest[1]
        when rest[3]
          params  = []
          trailer = rest[3]
        else
          params  = []
        end
        params ||= middle.split(" ")[1..-1]
        params << trailer if trailer
      end

      new(
        :prefix  => prefix,
        :command => command,
        :params  => params
      )
    end

    def initialize(args)
      @prefix  = args[:prefix]
      @command = args[:command]
      @params  = args[:params]
    end

    def to_s
      Azucat::Output.stringify(
        :name => (@prefix || "").split("!").first,
        :tag  => @command,
        :text => @params.join
      )
    end

    def to_hash
      {
        :name => (@prefix || "").split("!").first,
        :tag  => @command,
        :text => @params.join
      }
    end
  end
end
