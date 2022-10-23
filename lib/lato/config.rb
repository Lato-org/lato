module Lato
  # Config
  # This class contains the default configuration of the engine.
  ##
  class Config
    attr_accessor :application_title

    def initialize
      @application_title = 'Lato'
    end
  end
end
