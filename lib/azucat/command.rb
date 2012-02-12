module Azucat
  module Command
    extend self

    def input(str)
      output(str)
      exec_commands(str)
    end

    def register(pattern, help = nil, &block)
      if pattern.is_a?(String) || pattern.is_a?(Symbol)
        name, pattern = named_pattern(pattern, &block)
      end
      return if commands.any? { |c| c[:pattern] == pattern }
      commands << {
        :pattern => pattern,
        :name    => name,
        :help    => help,
        :arity   => block.arity,
        :proc    => block
      }
    end

    private

    def named_pattern(pattern, &block)
      name   = pattern.to_s
      regexp = (block.arity == 0) ?
        /^#{name}$/ :
        /^#{name}\s+(.*)$/
      [name, regexp]
    end

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
    rescue Exception => e
      Output.error(e)
    end

    def lines_by_ap(obj)
      result = obj.ai(:plain => true, :indent => 2)
      lines  = result.split(/\n|\\n/)
      if lines.first.match(/^\"/) and lines.last.match(/^\"$/)
        lines.first.gsub!(/^\"/, "")
        lines.pop
      end
      lines
    end

    register :help, "show help about commands" do
      explainables = []
      commands.each do |command|
        next unless command[:name]
        explainables << {
          :form => command[:name] + " <param>" * command[:arity],
          :help => command[:help]
        }
      end
      max   = explainables.map { |e| e[:form].length }.max
      lines = explainables.map do |e|
        line  = "%#{max}.#{max}s" % e[:form]
        line += " - #{e[:help]}" if e[:help]
        line
      end
      Output.puts(:name => "-" * 12, :tag => "-" * 4, :text => "-" * 70)
      Output.puts(lines)
      Output.puts(:name => "-" * 12, :tag => "-" * 4, :text => "-" * 70)
    end

    register :>, "eval <param>" do |m|
      Output.puts(lines_by_ap(eval m[1]))
    end
  end
end
