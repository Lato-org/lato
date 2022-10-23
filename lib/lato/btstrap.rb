module Lato
  # Btstrap
  # This class contains the default boostrap classes used on layout elements of the application.
  ##
  class Btstrap
    # Navbar classes
    attr_accessor :navbar, :navbar_container, :navbar_collapse

    # Content classes
    attr_accessor :content, :content_container

    # Footer classes
    attr_accessor :footer, :footer_container

    def initialize
      # Navbar defaults
      @navbar = 'navbar-light navbar-expand-lg fixed-top bg-light'
      @navbar_container = 'container-fluid'
      @navbar_collapse = 'justify-content-end'

      # Content defaults
      @content = 'content-fixed min-vh-100 py-3'
      @content_container = 'container-fluid'

      # Footer defaults
      @footer = 'bg-light py-3'
      @footer_container = 'container-fluid text-center text-muted'
    end
  end
end
