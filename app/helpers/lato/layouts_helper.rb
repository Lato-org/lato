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

    def lato_form_item_label(form, key, label, options = {})
      options[:class] = "form-label #{options[:class]}"

      form.label key, label, options
    end

    def lato_form_item_input_text(form, key, options = {})
      options[:class] = "form-control #{options[:class]}"

      form.text_field key, options
    end

    def lato_form_item_input_email(form, key, options = {})
      options[:class] = "form-control #{options[:class]}"

      form.email_field key, options
    end

    def lato_form_item_input_password(form, key, options = {})
      options[:class] = "form-control #{options[:class]}"

      form.password_field key, options
    end

    def lato_form_submit(form, label, options = {})
      options[:class] = "btn btn-primary #{options[:class]}"

      form.submit label, options
    end
  end
end
