module Azucat
  module Input
    extend self

    def run(args)
      STDIN.each { |line| Output.puts(line) }
    end
  end
end
