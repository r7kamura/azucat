module Azucat
  run do
    next unless config.stdin
    STDIN.each { |line| Output.puts(line) }
  end
end
