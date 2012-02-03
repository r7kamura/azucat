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
        ws.onopen do
          send_msg = proc do |msg|
            str = msg.respond_to?(:force_encoding) ?
              msg.force_encoding("UTF-8") : msg
            begin
              ws.send(str)
            rescue EventMachine::WebSocket::WebSocketError
            end
          end

          sid = channel.subscribe(&send_msg)
          logs.each(&send_msg)
          ws.onclose { channel.unsubscribe(sid) }
        end

        ws.onmessage do |msg|
          channel << msg
        end

        ws.onerror do |e|
          puts "#{Time.now} [SERVER] #{e.message}"
          puts e.backtrace.join("\n")
        end
      end
    end
  end
end
