module Azucat
  module Command
    extend self

    def input(str)
      commands.each do |com|
        com[:proc].call(str) if str.match com[:pattern]
      end
    end

    def register(pattern, &block)
      commands << {
        :pattern => pattern,
        :proc    => block
      }
    end

    private

    def commands
      @commands ||= []
    end
  end
end
