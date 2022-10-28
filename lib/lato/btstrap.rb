module Lato
  # Btstrap
  # This class contains the default boostrap classes used on layout elements of the application.
  ##
  class Btstrap
    # Navbar classes
    attr_accessor :navbar, :navbar_container, :navbar_collapse

    # Sidebar classes
    attr_accessor :sidebar

    # Content classes
    attr_accessor :content, :content_container

    # Footer classes
    attr_accessor :footer, :footer_container

    def initialize
      # Navbar defaults
      @navbar = 'navbar-light navbar-expand-lg fixed-top bg-light shadow-sm'
      @navbar_container = 'container-fluid'
      @navbar_collapse = 'justify-content-end'

      # Sidebar defaults
      @sidebar = 'p-3 bg-light border-end'

      # Content defaults
      @content = 'content-fixed p-3'
      @content_container = 'container-fluid'

      # Footer defaults
      @footer = 'bg-light py-3'
      @footer_container = 'container-fluid text-center text-muted'
    end
  end
end
