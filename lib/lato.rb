require "kaminari"
require "bootstrap"
require "browser"
require "rotp"
require "rqrcode"

require "lato/version"
require "lato/engine"
require "lato/config"
require "lato/btstrap"
require "lato/dependency_helper"

module Lato
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end

    def btstrap
      @btstrap ||= Btstrap.new
    end

    def bootstrap
      yield btstrap
    end
  end
end
