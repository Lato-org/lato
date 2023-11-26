module Lato
  module Layoutable
    extend ActiveSupport::Concern

    included do
      before_action do
        show_sidebar

        @layout_page_title = Lato.config.application_title
        @layout_body_classes = []
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

    def page_title(title)
      @layout_page_title = title
    end

    def page_class(class_name)
      @layout_body_classes << class_name
    end

    def page_classes(classes)
      @layout_body_classes = classes
    end
  end
end
