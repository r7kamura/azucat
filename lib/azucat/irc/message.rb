module Azucat::IRC
  class Message
    attr_reader :prefix, :command, :params

    class InvalidMessage < StandardError; end
    def self.parse(str)
      all, prefix, command, *rest = Pattern::MESSAGE_PATTERN.match(str).to_a
      raise InvalidMessage unless all

      {
        :name => (prefix || "").split("!").first,
        :tag  => command,
        :text => convert_to_params(rest).join(" ")
      }
    end

    private

    def self.convert_to_params(rest)
      params = []
      case
      when !rest[0].blank?
        middle, trailer, = *rest
        params = middle.split(" ")
      when !rest[2].blank?
        middle, trailer, = *rest[2, 2]
        params = middle.split(" ")
      when rest[1]
        trailer = rest[1]
      when rest[3]
        trailer = rest[3]
      end
      params << trailer if trailer
      params
    end
  end
end
