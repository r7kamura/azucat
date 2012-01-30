module WebTail
  class WebSocketServer
    def self.run(args)
      channel = args[:channel]
      logs    = args[:logs]

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
    end
  end
end
