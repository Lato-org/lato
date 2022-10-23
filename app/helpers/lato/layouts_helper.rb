module Lato
  module LayoutsHelper
    def lato_navbar_nav_item(content, path, key = nil)
      is_active = request.path == path

      content_tag :li, class: 'nav-item' do
        link_to path, class: "nav-link #{is_active ? 'active' : ''}" do
          content
        end
      end
    end
  end
end
