module Azucat
  module Input
    extend self

    def run(args)
      return unless args[:stdin]
      STDIN.each { |line| Output.puts(line) }
    end
  end
end
