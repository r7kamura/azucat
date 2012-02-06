module Azucat
  module Output
    extend self

    COLORS = (31..36).to_a + (91..96).to_a
    COLOR_MAP = {}.tap do |map|
      Term::ANSIColor::ATTRIBUTES.each do |color, code|
        map[code.to_s] = color.to_s.gsub("_", "-")
      end
    end

    # define accessor of class instance variable
    # example:
    #   Output.channel
    #   Output.channel= EM::Channel.new
    class << self; attr_accessor :channel; end

    def puts(obj)
      return if obj.blank?
      str = uniform(obj)

      uncolored = ::Term::ANSIColor.uncolored(str).strip
      notify(
        :filtered => uncolored,
        :title    => uncolored.split(": ", 2)[0],
        :message  => uncolored.split(": ", 2)[1]
      )
      STDOUT.puts(unhtmlize(str))
      channel << htmlize(str)
    end

    def colorize(str)
      return str if str.blank?
      code = COLORS[str.to_i(36) % COLORS.size]
      "\e\[#{code}m#{str}\e\[0m"
    end

    def stringify(hash)
      name = colorize("%14.14s" % hash[:name])
      tag  = "%4.4s" % hash[:tag]
      text = hash[:text]
      "#{name}: [#{tag}] #{text}"
    end

    def notify(args = {}, &block)
      @notify_filters ||= []

      if block
        @notify_filters << block
      else
        if @notify_filters.map { |proc| proc.call(args[:filtered]) }.any?
          Notify.notify args[:title], args[:message]
        end
      end
    end

    private
    def htmlize(str)
      str.gsub(/(?:\e\[([0-9;]*)m)/) do
        $1 == "0" ?
          %{</span>} :
          %{<span class="#{color_class_from_codes($1)}">}
      end
    end

    t = {
      ?& => "&amp;",
      ?< => "&lt;",
      ?> => "&gt;",
      ?' => "&apos;",
      ?" => "&quot;",
    }
    def unhtmlize(str)
      str.gsub(/(#{Regexp.union(t.values)})/o, t.invert)
    end

    def color_class_from_codes(codes)
      codes = codes.split(";") if codes.class == String
      codes.map { |code| COLOR_MAP[code] }.join(" ")
    end

    def uniform(obj)
      str = obj.class == Hash ?
        stringify(obj) : obj.to_s
      str.gsub("\n", "")
    end
  end
end
