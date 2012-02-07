class Azucat::Browser
  def self.run
    open_browser = Azucat.config.open_browser
    http_host    = Azucat.config.http_host
    http_port    = Azucat.config.http_port

    return unless open_browser
    EM.defer {
      sleep 1 # wait for starting HTTP server
      ::Launchy.open("http://#{http_host}:#{http_port}")
    }
  end
end
