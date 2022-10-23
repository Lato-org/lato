module Lato
  # Btstrap
  # This class contains the default boostrap classes used on layout elements of the application.
  ##
  class Btstrap
    attr_accessor :navbar, :navbar__container

    def initialize
      @navbar = 'navbar-light bg-light'
      @navbar__container = 'container-fluid'
    end
  end
end
