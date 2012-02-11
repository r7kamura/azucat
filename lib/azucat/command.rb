module Azucat
  module Command
    extend self

    def input(str)
      output(str)
      exec_commands(str)
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

    def output(str)
      Output.puts(
        :name => "your input",
        :tag  => "<<>>",
        :text => str
      )
    end

    def exec_commands(str)
      commands.each do |command|
        if m = str.match(command[:pattern])
          command[:proc].call(m)
        end
      end
    end
  end
end
