module Lato
  # Btstrap
  # This class contains the default boostrap classes used on layout elements of the application.
  ##
  class Btstrap
    attr_accessor :navbar, :navbar__container, :navbar__collapse

    def initialize
      @navbar = 'navbar-light bg-light navbar-expand-lg'
      @navbar__container = 'container-fluid'
      @navbar__collapse = 'justify-content-end'
    end
  end
end
