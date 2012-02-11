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
        :tag  => ">>>>",
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

    register /^help$/ do
      lines = File.read(Azucat.config.root + "/README.md").split("\n")
      num   = lines.size

      Output.puts(:name => "README.md", :tag => "----", :text => "-" * 70)
      lines.reverse_each do |line|
        Output.puts(:tag => num, :text => line)
        num -= 1
      end
      Output.puts(:name => "README.md", :tag => "----", :text => "-" * 70)
    end

    register /^> (.+)/ do |m|
      begin
        lines = eval(m[1]).ai(:plain => true, :indent => 2).split(/\n|\\n/)
        if lines.first.match(/^\"/) and lines.last.match(/^\"$/)
          lines.first.gsub!(/^\"/, "")
          lines.pop
        end
        num   = lines.size

        lines.reverse_each do |line|
          Output.puts(
            :name => "result",
            :tag  => num,
            :text => line
          )
          num -= 1
        end
      rescue Exception => e
        Output.puts(
          :name => "ERROR",
          :text => "#{e.class} - #{e.message}"
        )
      end
    end
  end
end
