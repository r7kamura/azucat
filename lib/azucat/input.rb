module Azucat
  module Input
    extend self

    def run
      return unless Azucat.config.stdin
      STDIN.each { |line| Output.puts(line) }
    end
  end
end
