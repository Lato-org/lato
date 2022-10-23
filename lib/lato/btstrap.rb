module Lato
  # Btstrap
  # This class contains the default boostrap classes used on layout elements of the application.
  ##
  class Btstrap
    attr_accessor :navbar, :navbar_container, :navbar_collapse

    def initialize
      @navbar = 'navbar-light bg-light navbar-expand-lg'
      @navbar_container = 'container-fluid'
      @navbar_collapse = 'justify-content-end'
    end
  end
end
