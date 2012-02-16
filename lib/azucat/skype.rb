module Azucat
  module Skype
    extend self

    POLLING_SEC = 30

    Azucat.init do
      @used_skype_messages = {}
    end

    Azucat.init do
      Skype.on_message do |msg|
        unique_key = msg.values.join
        Azucat::Output.puts(
          :name => msg[:from_handle],
          :tag  => "SKYP",
          :text => msg[:body]
        )
      end
    end

    def run
      if !Azucat.config.skype || !RUBY_PLATFORM.downcase.include?("darwin")
        return
      end

      @start_time = Time.now
      loop do
        start  = Time.now
        messages = gets
        finish = Time.now

        sleep_time = POLLING_SEC - (finish - start)
        sleep sleep_time if sleep_time > 0
      end
    end

    def on_message(msg = nil, &block)
      @on_messages ||= []
      block ?
        @on_messages << block :
        @on_messages.each { |proc| proc.call(msg) }
    end

    def gets
      recent_messages.each { |msg| on_message(msg) }
    end

    def recent_messages
      messages = []
      recent_chat_ids.each do |chat_id|
        recent_message_ids(chat_id).each do |msg_id|
          next if @used_skype_messages[msg_id]
          msg = message(msg_id)
          messages << msg if msg[:time] >= @start_time
          @used_skype_messages[msg_id] = true
        end
      end
      messages.sort_by! { |msg| msg[:timestamp] }
    end

    def message(id)
      {}.tap do |hash|
        %w[from_handle body timestamp].each do |key|
          result = skype("get chatmessage #{id} #{key}")
          hash[key.to_sym] = result.split(" ", 4).last
        end
        hash[:time] = Time.new(1970) + 9.hours + hash[:timestamp].to_i
      end
    end

    def recent_message_ids(chat_id)
      result  = skype("get chat #{chat_id} recentchatmessages")
      msg_ids = result.split(/,? /).select { |str| str =~ /^\d+/ }
      msg_ids.sort.reverse
    end

    def recent_chat_ids
      result   = skype("search recentchats")
      chat_ids = result.split("CHATS ", 2).last.split(", ")
    end

    def skype(command)
      SkypeMac::Skype.send_(:command => command)
    end
  end
end
