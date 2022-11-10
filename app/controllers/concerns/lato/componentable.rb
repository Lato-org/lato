module Lato
  module Componentable
    extend ActiveSupport::Concern

    included do
      before_action do
        show_sidebar
      end
    end

    def lato_index_collection(collection, options = {})
      # load options
      # NOTE: instance variables are for options used by "lato_index" component helper
      @_lato_index_columns = options[:columns] || collection.column_names || []
      @_lato_index_sortable_columns = options[:sortable_columns] || []
      pagination = options[:pagination] || false

      # manage sort by parameter
      unless params[:sort_by].blank?
        sort_by_splitted = params[:sort_by].split('|')
        sort_by_column = sort_by_splitted.first
        sort_by_order = sort_by_splitted.last

        if @_lato_index_sortable_columns.include?(sort_by_column.to_sym)
          if collection.respond_to?(:lato_index_sort)
            collection = collection.lato_index_sort(sort_by_column.to_sym, sort_by_order.to_sym)
          else
            collection = collection.order("#{sort_by_column} #{sort_by_order}")
          end
        end
      end

      # manage total (before pagination)
      @_lato_index_total = collection.count

      # manage pagination
      if params[:page] || params[:per_page] || pagination
        page = params[:page]&.to_i || 1
        per_page = params[:per_page]&.to_i || 25
        per_page = 100 if per_page > 100
        collection = collection.page(page).per(per_page)
      end

      collection
    end
  end
end
