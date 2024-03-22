module Lato
  module Componentable
    extend ActiveSupport::Concern

    def lato_index_collection(collection, options = {})
      # load options
      # NOTE: instance variables are for options used by "lato_index" component helper
      key = options[:key] || 'default'
      pagination = options[:pagination] || false
      default_sort_by = options[:default_sort_by] || nil
      @_lato_index ||= {}
      @_lato_index[key] = {
        columns: options[:columns] || collection.column_names || [],
        sortable_columns: options[:sortable_columns] || [],
        searchable_columns: options[:searchable_columns] || []
      }

      # manage default sort by parameter
      params[:sort_by] = default_sort_by if params[:sort_by].blank? && default_sort_by

      # manage sort by parameter
      unless params[:sort_by].blank?
        sort_by_splitted = params[:sort_by].split('|')
        sort_by_column = sort_by_splitted.first
        sort_by_order = sort_by_splitted.last

        if collection.respond_to?(:lato_index_order)
          collection = collection.lato_index_order(sort_by_column.to_sym, sort_by_order.to_sym)
        else
          collection = collection.order("#{sort_by_column} #{sort_by_order}")
        end
      end

      # manage search by parameter
      unless params[:search].blank?
        search = params[:search].to_s
        if collection.respond_to?(:lato_index_search)
          collection = collection.lato_index_search(search)
        else
          query = @_lato_index[key][:searchable_columns].map { |k| "#{k.to_s == 'id' ? k : "lower(#{k})"} LIKE :search" }
          collection = collection.where(query.join(' OR '), search: "%#{search.downcase.strip}%")
        end
      end

      # manage pagination
      if pagination || params[:page] || params[:per_page]
        page = params[:page]&.to_i || 1
        per_page = params[:per_page]&.to_i || 25
        per_page = 100 if per_page > 100
        collection = collection.page(page).per(per_page)
      end

      collection
    end
  end
end
