module Lato
  module LayoutsHelper
    # Navbar
    ##

    def lato_navbar_nav_item(content, path, key = nil)
      is_active = request.path == path

      content_tag :li, class: 'nav-item' do
        link_to path, class: "nav-link #{is_active ? 'active' : ''}" do
          content
        end
      end
    end

    # Forms
    ##

    def lato_form_errors(instance, options = {})
      return unless instance.errors.any?

      content_tag :div, options do
        content_tag :div, class: %w[alert alert-danger mb-0] do
          content_tag :ul, class: %w[mb-0] do
            instance.errors.collect do |error|
              content_tag :li, error.full_message
            end.join.html_safe
          end
        end
      end
    end

    def lato_form_item_label(form, key, label, options = {})
      options[:class] ||= []
      options[:class].push('form-label')

      form.label key, label, options
    end

    def lato_form_item_input_text(form, key, options = {})
      options[:class] ||= []
      options[:class].push('form-control')


      form.text_field key, options
    end

    def lato_form_item_input_email(form, key, options = {})
      options[:class] ||= []
      options[:class].push('form-control')


      form.email_field key, options
    end

    def lato_form_item_input_password(form, key, options = {})
      options[:class] ||= []
      options[:class].push('form-control')


      form.password_field key, options
    end

    def lato_form_submit(form, label, options = {})
      options[:class] ||= []
      options[:class].push('btn')
      options[:class].push('btn-primary')

      form.submit label, options
    end
  end
end
