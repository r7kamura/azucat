module Azucat
  module Output
    extend self

    COLORS = (31..36).to_a + (91..96).to_a
    COLOR_MAP = {}.tap do |map|
      Term::ANSIColor::ATTRIBUTES.each do |color, code|
        map[code.to_s] = color.to_s.gsub("_", "-")
      end
    end
    ENTITY_MAP = {
      ?& => "&amp;",
      ?< => "&lt;",
      ?> => "&gt;",
      ?' => "&apos;",
      ?" => "&quot;"
    }

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
      Azucat.config.channel << htmlize(str)
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
      result = str.gsub(/(#{Regexp.union(ENTITY_MAP.keys)})/o, ENTITY_MAP)
      result.gsub(/(?:\e\[([0-9;]*)m)/) do
        $1 == "0" ?
          %{</span>} :
          %{<span class="#{color_class_from_codes($1)}">}
      end
    end

    def unhtmlize(str)
      str.gsub(/(#{Regexp.union(ENTITY_MAP.values)})/o, ENTITY_MAP.invert)
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
