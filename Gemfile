source "http://rubygems.org"

gem "em-websocket"                                          # WS server
gem "sinatra", :require => "sinatra/base"                   # HTTP server
gem "launchy", "~> 2.0.5"                                   # Open Browser
gem "term-ansicolor", :require => "term/ansicolor"          # ANSI to HTML
gem "oauth"                                                 # Twitter
gem "twitter-stream", :require => "twitter/json_stream"     # Twitter
gem "twitter_oauth"                                         # Twitter
gem "i18n"                                                  # for ActiveSupport
gem "active_support", :require => "active_support/core_ext" # Utility
gem "hashie"                                                # Utility
gem "notify"                                                # Growl
gem "bundler", "~> 1.0.0"                                   # Bundle.require

if RUBY_PLATFORM.downcase.include?("darwin")                # Mac
  gem "rb-skypemac", :git => "https://github.com/r7kamura/rb-skypemac.git"
end

group :development do
  gem "pry"
  gem "awesome_print"
end
