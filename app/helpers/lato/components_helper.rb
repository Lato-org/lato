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

    def lato_navbar_nav_locales_item(options = {})
      flag = options[:flag] || false

      render 'lato/components/navbar_nav_locales_item', flag: flag
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
      sortable_columns = @_lato_index[key][:sortable_columns] || []
      searchable_columns = @_lato_index[key][:searchable_columns] || []
      model_name = options[:model_name] || collection.model.name
      model_name_underscore = options[:model_name] || model_name.underscore.gsub('/', '_')
      pagination_options = options[:pagination_options] || nil

      render(
        'lato/components/index',
        key: key,
        collection: collection,
        columns: columns,
        sortable_columns: sortable_columns,
        searchable_columns: searchable_columns,
        model_name: model_name,
        model_name_underscore: model_name_underscore,
        pagination_options: pagination_options,
        custom_actions: options[:custom_actions] || {},
        dropdown_actions: options[:dropdown_actions] || nil
      )
    end

    def lato_index_dynamic_label(params = {})
      'Please override the method lato_index_dynamic_label in your application_helper.rb'
    end

    def lato_index_dynamic_value(params = {})
      'Please override the method lato_index_dynamic_value in your application_helper.rb'
    end

    # Operation
    ##

    def lato_operation(operation)
      render(
        'lato/components/operation',
        operation: operation
      )
    end

    # Forms
    ##

    def _lato_form_input_options(form, key, options, action_change_event, classes = '')
      # setup classes
      options[:class] ||= []
      options[:class].push(classes)
      options[:class].push('is-invalid') if form.object && form.object.errors[key] && form.object.errors[key].any?

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
        concat content_tag(:span, "#{I18n.t('lato.there_are_some_errors')}:")
        concat errors_list
        concat button_tag('', type: 'button', class: 'btn-close', data: { bs_dismiss: 'alert' }) unless options[:fixed]
      end
    end

    def lato_form_item_label(form, key, label = nil, options = {})
      options[:class] ||= []
      options[:class].push('form-label')

      form.label key, label, options
    end

    def lato_form_item_input_text(form, key, options = {})
      _lato_form_input_options(form, key, options, :keyup, 'form-control')

      form.text_field key, options
    end

    def lato_form_item_input_number(form, key, options = {})
      _lato_form_input_options(form, key, options, :keyup, 'form-control')

      form.number_field key, options
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

    def lato_form_item_input_select(form, key, select_options = [], options = {})
      _lato_form_input_options(form, key, options, :change, 'form-control')

      form.select key, select_options, {}, options
    end

    def lato_form_item_input_file(form, key, options = {})
      _lato_form_input_options(form, key, options, :change, 'form-control')

      form.file_field key, options
    end

    def lato_form_item_input_textarea(form, key, options = {})
      _lato_form_input_options(form, key, options, :keyup, 'form-control')

      form.text_area key, options
    end

    def lato_form_item_input_date(form, key, options = {})
      _lato_form_input_options(form, key, options, :change, 'form-control')

      form.date_field key, options
    end

    def lato_form_item_input_datetime(form, key, options = {})
      _lato_form_input_options(form, key, options, :change, 'form-control')

      form.datetime_field key, options
    end

    def lato_form_submit(form, label, options = {})
      options[:class] ||= []
      options[:class].push('btn')
      options[:class].push('btn-primary')

      options[:data] ||= {}
      options[:data][:lato_form_target] = 'submit'

      form.submit label, options
    end

    # Data
    ##

    def lato_data_badge(label, color = 'primary')
      content_tag :span, label, class: "badge rounded-pill bg-#{color}"
    end

    def lato_data_user(label, image_url = nil)
      image_url ||= image_path('lato/user-150x150.jpg')

      content_tag :div, class: 'd-flex align-items-center' do
        concat content_tag :div, '', class: 'border border-2 rounded-circle me-2', style: "background-position: center; background-size: cover; background-repeat: no-repeat; background-image: url(#{image_url}); width: 30px; height: 30px;"
        concat content_tag :small, label, class: 'text-black'
      end
    end
  end
end
