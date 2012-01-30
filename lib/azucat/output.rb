module Azucat
  class Output
    def self.run(channel)
      color_map = {}.tap { |map|
        Term::ANSIColor::ATTRIBUTES.each do |color, code|
          map[code.to_s] = color.to_s.gsub("_", "-")
        end
      }

      STDIN.each do |line|
        STDOUT.puts line

        channel << line.gsub(/(?:\e\[([0-9;]*)m)/) {
          if $1 == "0"
            %{</span>}
          else
            color_class = $1.split(";").map { |code| color_map[code] }.join(" ")
            %{<span class="#{color_class}">}
          end
        }
      end
    end
  end
end
