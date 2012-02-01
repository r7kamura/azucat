module Azucat
  class Input
    def self.run(args)
      STDIN.each { |line| Output.puts(line) }
    end
  end
end
