$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "azucat"
Bundler.require(:test)

RSpec.configure do |config|
end
