module Azucat
  module Core
    def run(opts = {}, &block)
      @runs ||= []
      if block
        @runs << block
      else
        configure(opts)
        init
        care_thread
        run_threads
      end
    end

    def init(&block)
      @inits ||= []
      block ? @inits << block : @inits.each(&:call)
    end

    def config
      @config ||= Hashie::Mash.new(
        :root            => File.expand_path("../../../", __FILE__),
        :file            => File.expand_path("~/.azucat"),
        :log_size        => 100,
        :ws_port         => unused_port,
        :ws_host         => "localhost",
        :http_port       => unused_port,
        :http_host       => "localhost",
        :open_browser    => true,
        :channel         => EM::Channel.new,
        :consumer_key    => "B2tZeyZ96bB7BdQuk6r0A",
        :consumer_secret => "iA5pDiQpNaAjFw6FwWSwDUVFppU4dHVxicprAcPRak"
      )
    end

    def stop
      EM.stop_event_loop
    end

    private

    def configure(opts = {})
      config.merge!(opts)
      load_or_create_config_file
    end

    def load_or_create_config_file
      file = config[:file]
      File.exists?(file) ? load(file) : File.open(file, "w")
    end

    def care_thread
      trap('INT') { exit! }
      Thread.abort_on_exception = true
    end

    def unused_port
      s = ::TCPServer.open(0)
      port = s.addr[1]
      s.close
      port
    end

    def run_threads
      EM.run do
        @runs.each do |r|
          EM.defer { r.call }
        end
      end
    end
  end
end
