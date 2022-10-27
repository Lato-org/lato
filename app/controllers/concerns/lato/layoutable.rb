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
  end
end