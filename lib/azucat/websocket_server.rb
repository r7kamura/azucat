module Azucat
  run do
    logs = []

    config.channel.subscribe do |msg|
      logs << msg
      logs.shift if logs.size > config.log_size
    end

    EM::WebSocket.start(
      :host => config.ws_host,
      :port => config.ws_port
    ) do |ws|
      ws.onopen do
        send_msg = proc do |msg|
          next unless msg
          str = msg.respond_to?(:force_encoding) ?
            msg.force_encoding("UTF-8") : msg
          begin
            ws.send(str)
          rescue EventMachine::WebSocket::WebSocketError
          end
        end

        sid = config.channel.subscribe(&send_msg)
        logs.each(&send_msg)
        ws.onclose { config.channel.unsubscribe(sid) }
      end

      ws.onmessage { |msg| config.channel << msg }
      ws.onerror { |e| Output.error(e) }
    end
  end
end
