module Lato
  module Layoutable
    extend ActiveSupport::Concern

    included do
      before_action do
        show_sidebar
      end
    end

    def show_sidebar
      @layout_sidebar = true
    end

    def hide_sidebar
      @layout_sidebar = false
    end

    def active_sidebar(key)
      @sidebar_key = key
    end

    def active_navbar(key)
      @navbar_key = key
    end
  end
end
