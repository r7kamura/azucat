module Azucat
  run do
    return unless config.stdin
    STDIN.each { |line| Output.puts(line) }
  end
end
