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
      commands.each { |c| m = str.match(c[:pattern]) and c[:proc].call(m) }
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

    def explainable_commands
      commands.select { |c| c[:name] }
    end

    def form_and_help(command)
      {
        :form => command[:name] + " <param>" * command[:arity],
        :help => command[:help]
      }
    end

    def pretty_help
      commands = explainable_commands.map(&method(:form_and_help))
      max      = commands.map { |c| c[:form].length }.max
      commands.map { |c|
        ["%#{max}.#{max}s" % c[:form], c[:help]].compact.join(" - ")
      }
    end

    def output_pretty_help
      Output.puts(:name => "-" * 12, :tag => "-" * 4, :text => "-" * 70)
      Output.puts(pretty_help)
      Output.puts(:name => "-" * 12, :tag => "-" * 4, :text => "-" * 70)
    end

    def output_eval(input)
      Output.puts(lines_by_ap(eval input))
    end

    register(:help, "show help about commands") { output_pretty_help }
    register(:>, "eval <param> as Ruby command") { |m| output_eval(m[1]) }
  end
end
