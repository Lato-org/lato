module Lato
  module LayoutsHelper
    # Navbar
    ##

    def lato_navbar_nav_item(key, path, &block)
      is_active = request.path == path
      is_active = @navbar_key == key if @navbar_key

      content_tag :li, class: 'nav-item' do
        link_to path, class: "nav-link #{is_active ? 'active' : ''}" do
          yield
        end
      end
    end

    # Sidebar
    ##

    def lato_sidebar_nav_item(key, path, &block)
      is_active = request.path == path
      is_active = @sidebar_key == key if @sidebar_key

      content_tag :li, class: 'nav-item border-bottom py-2' do
        link_to path, class: "nav-link #{is_active ? 'active' : 'link-dark'}" do
          yield
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

    # Page head
    ##

    def lato_page_head(title, &block)
      content_tag :div do
        concat content_tag :h1, title
        yield if block
      end
    end
  end
end
