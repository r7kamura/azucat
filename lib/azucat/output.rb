module Azucat
  class Output
    COLOR_MAP = {}.tap { |map|
      Term::ANSIColor::ATTRIBUTES.each do |color, code|
        map[code.to_s] = color.to_s.gsub("_", "-")
      end
    }

    # define class instance variable and it's accessor
    # example:
    #   Output.channel
    #   Output.channel= EM::Channel.new
    @channel = nil
    class << self; attr_accessor :channel; end

    def self.puts(obj)
      STDOUT.puts obj
      channel << colorize(obj.to_s)
    end

    private
    def self.colorize(str)
      str.gsub(/(?:\e\[([0-9;]*)m)/) do
        if $1 == "0"
          %{</span>}
        else
          color_class = $1.split(";").map { |code| COLOR_MAP[code] }.join(" ")
          %{<span class="#{color_class}">}
        end
      end
    end
  end
end
