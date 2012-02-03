class Azucat::Browser
  def self.open(args)
    open_browser = args[:open_browser]
    http_host    = args[:http_host]
    http_port    = args[:http_port]

    return unless open_browser
    EM.defer {
      sleep 1 # wait for starting HTTP server
      ::Launchy.open("http://#{http_host}:#{http_port}")
    }
  end
end
