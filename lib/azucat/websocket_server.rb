module Azucat
  class WebSocketServer
    def self.run(args)
      channel  = args[:channel]
      port     = args[:ws_port]
      host     = args[:ws_host]
      log_size = args[:log_size]

      logs = []
      channel.subscribe do |msg|
        logs << msg
        logs.shift if logs.size > log_size
      end

      EM::WebSocket.start(:host => host, :port => port) do |ws|
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
