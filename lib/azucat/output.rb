module Azucat
  class Output
    COLOR_MAP = {}.tap { |map|
      Term::ANSIColor::ATTRIBUTES.each do |color, code|
        map[code.to_s] = color.to_s.gsub("_", "-")
      end
    }

    # define accessor of class instance variable
    # example:
    #   Output.channel
    #   Output.channel= EM::Channel.new
    @channel = nil
    class << self; attr_accessor :channel; end

    def self.puts(obj)
      return if obj.blank?

      str = obj.to_s
      STDOUT.puts str
      channel << htmlize(str)
    end

    def self.random_colorize(str)
      code = COLORS[str.to_i(36) % COLORS.size]
      "\e\[#{code}m#{str}\e\[0m"
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
