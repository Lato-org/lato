module Lato
  module ComponentsHelper
    # Navbar
    ##

    def lato_navbar_nav_item(key, path, &block)
      active = request.path == path
      active = @navbar_key == key if @navbar_key

      render 'lato/components/navbar_nav_item', active: active, path: path do
        yield if block
      end
    end

    # Sidebar
    ##

    def lato_sidebar_nav_item(key, path, &block)
      active = request.path == path
      active = @sidebar_key == key if @sidebar_key

      render 'lato/components/sidebar_nav_item', active: active, path: path do
        yield if block
      end
    end

    # Page head
    ##

    def lato_page_head(title, breadcrumbs = [], &block)
      render 'lato/components/page_head', title: title, breadcrumbs: breadcrumbs do
        yield if block
      end
    end

    # Index
    ##

    def lato_index(collection, options = {})
      key = options[:key] || 'default'

      @_lato_index ||= {}
      @_lato_index[key] ||= {}
      columns = options[:columns] || @_lato_index[key][:columns] || collection.column_names || []
      sortable_columns = options[:sortable_columns] || @_lato_index[key][:sortable_columns] || []
      model_name_underscore = collection.model.name.underscore

      render(
        'lato/components/index',
        key: key,
        collection: collection,
        columns: columns,
        sortable_columns: sortable_columns,
        model_name_underscore: model_name_underscore
      )
    end

    # Forms
    ##

    def _lato_form_input_options(form, key, options, action_change_event, classes = '')
      # setup classes
      options[:class] ||= []
      options[:class].push(classes)
      options[:class].push('is-invalid') unless form.object.errors[key].blank?

      # setup stimulus
      options[:data] ||= {}
      options[:data][:action] ||= ''
      options[:data][:action] += " #{action_change_event}->lato-form#onInputChange"
      options[:data][:lato_form_target] = 'input'
    end

    def lato_form_notices(options = {})
      return unless notice

      options[:class] ||= []
      options[:class] += %w[alert alert-success]
      options[:class] += %w[alert-dismissible fade show] unless options[:fixed]

      content_tag :div, options do
        concat notice
        concat button_tag('', type: 'button', class: 'btn-close', data: { bs_dismiss: 'alert' }) unless options[:fixed]
      end
    end

    def lato_form_errors(instance, options = {})
      return unless instance.errors.any?

      options[:class] ||= []
      options[:class] += %w[alert alert-danger]
      options[:class] += %w[alert-dismissible fade show] unless options[:fixed]

      errors_list = content_tag(:ul, class: %w[mb-0 ps-3]) do
        instance.errors.collect do |error|
          content_tag :li, error.full_message
        end.join.html_safe
      end

      content_tag :div, options do
        concat content_tag(:span, 'Si sono verificati i seguenti errori:')
        concat errors_list
        concat button_tag('', type: 'button', class: 'btn-close', data: { bs_dismiss: 'alert' }) unless options[:fixed]
      end
    end

    def lato_form_item_label(form, key, label, options = {})
      options[:class] ||= []
      options[:class].push('form-label')

      form.label key, label, options
    end

    def lato_form_item_input_text(form, key, options = {})
      _lato_form_input_options(form, key, options, :keyup, 'form-control')

      form.text_field key, options
    end

    def lato_form_item_input_email(form, key, options = {})
      _lato_form_input_options(form, key, options, :keyup, 'form-control')

      form.email_field key, options
    end

    def lato_form_item_input_password(form, key, options = {})
      _lato_form_input_options(form, key, options, :keyup, 'form-control')

      form.password_field key, options
    end

    def lato_form_item_input_check(form, key, label, options = {})
      _lato_form_input_options(form, key, options, :change, 'form-check-input')

      # TO-DO: Trovare il modo di calcolare l'id dato da rails a check_input_tag e metterlo nell'attributo :for di check_label_tag

      content_tag :div, class: 'form-check' do
        concat form.check_box(key, options)
        concat label_tag(key, raw(label), class: 'form-check-label')
      end
    end

    def lato_form_submit(form, label, options = {})
      options[:class] ||= []
      options[:class].push('btn')
      options[:class].push('btn-primary')

      options[:data] ||= {}
      options[:data][:lato_form_target] = 'submit'

      form.submit label, options
    end
  end
end