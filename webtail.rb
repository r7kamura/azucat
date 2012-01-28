#!/usr/bin/env ruby

require "rubygems"
require "rack"
require "em-websocket"

# WEBrick compatible for 1.9
class String; alias_method :each, :lines; end

html = <<-"EOF"
<!DOCTYPE HTML>
<html>
<head>
  <meta charset="UTF-8">
  <title></title>
  <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
  <script type="text/javascript">
    $(function() {
      var ws = new WebSocket("ws://localhost:4000");
      ws.onmessage = function(e) {
        $(document.body).append("<p>" + e.data + "</p>");
      };
    });
  </script>
</head>
<body>
</body>
</html>
EOF

# launch HTTP server
Thread.new do
  app = proc { [200, {"Content-Type" => "text/html; charset=UTF-8"}, html] }
  Rack::Handler::WEBrick.run(app, :Port => 9292)
end
system("open http://localhost:9292")

# launch WS server
EM::run do
  logs = []
  channel = EM::Channel.new.tap do |channel|
    channel.subscribe do |msg|
      logs << msg
      logs.shift if logs.size > 10
    end
  end

  EM::WebSocket.start(:host => "127.0.0.1", :port => 4000) do |ws|
    ws.onopen {
      send_msg = proc { |msg| ws.send(msg.encode("UTF-8")) }
      sid = channel.subscribe(&send_msg)
      logs.each(&send_msg)
      ws.onclose { channel.unsubscribe(sid) }
    }
    ws.onmessage { |msg| channel << msg }
    ws.onerror { |e|
      puts "#{Time.now} [SERVER] #{e.message}"
      puts e.backtrace.join("\n")
    }
  end

  # handle STDIN
  EM::defer do
    STDIN.each { |line| channel << line }
  end
end
