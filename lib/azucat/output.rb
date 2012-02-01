module Azucat
  class Output
    COLORS = (31..36).to_a + (91..96).to_a
    COLOR_MAP = {}.tap { |map|
      Term::ANSIColor::ATTRIBUTES.each do |color, code|
        map[code.to_s] = color.to_s.gsub("_", "-")
      end
    }

    # define class instance variable and it's accessor
    # example:
    #   Output.channel
    #   Output.channel= EM::Channel.new
    class << self; attr_accessor :channel; end

    def self.puts(obj)
      STDOUT.puts obj
      channel << htmlize(obj.to_s)
    end

    def self.random_colorize(str)
      code = COLORS[str.to_i(36) % COLORS.size]
      "\e\[#{code}m#{str}\e\[0m"
    end

    private
    def self.htmlize(str)
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
