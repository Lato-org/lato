require "lato/version"
require "lato/engine"
require "lato/config"

module Lato
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end
end
