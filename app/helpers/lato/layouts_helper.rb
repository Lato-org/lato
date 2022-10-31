module Lato
  module LayoutsHelper
    # Navbar
    ##

    def lato_navbar_nav_item(key, path, &block)
      is_active = request.path == path
      is_active = @navbar_key == key if @navbar_key

      content_tag :li, class: 'nav-item' do
        link_to path, class: "nav-link #{is_active ? 'active' : ''}" do
          yield if block
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
          yield if block
        end
      end
    end

    # Forms
    ##

    def lato_form_notices(options = {})
      return unless notice

      content_tag :div, class: %w[alert alert-success alert-dismissible fade show mb-3] do
        concat notice
        concat button_tag '', type: 'button', class: 'btn-close', data: { bs_dismiss: 'alert' }
      end
    end

    def lato_form_errors(instance, options = {})
      return unless instance.errors.any?

      content_tag :div, options do
        content_tag :div, class: %w[alert alert-danger mb-3] do
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

    def lato_page_head(title, breadcrumbs = [], &block)
      title_tag = content_tag :h1, title

      if breadcrumbs.length.positive?
        breadcrumbs_tag = content_tag :ol, class: %w[breadcrumb mb-0] do
          breadcrumbs.collect do |breadcrumb|
            content_tag :li, class: %w[breadcrumb-item] do
              link_to breadcrumb[:label], breadcrumb[:path]
            end
          end.join.html_safe
        end
      else
        breadcrumbs_tag = nil
      end

      content_tag :div, class: %w[border-bottom mb-3] do
        concat breadcrumbs_tag
        concat title_tag
        yield if block
      end
    end
  end
end
