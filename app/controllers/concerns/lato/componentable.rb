module Lato
  module Componentable
    extend ActiveSupport::Concern

    def lato_index_collection(collection, options = {})
      # load options
      # NOTE: instance variables are for options used by "lato_index" component helper
      key = options[:key] || 'default'
      default_sort_by = options[:default_sort_by] || nil
      pagination = options[:pagination] || false
      @_lato_index ||= {}
      @_lato_index[key] = {
        columns: options[:columns] || collection.column_names || [],
        sortable_columns: options[:sortable_columns] || [],
        searchable_columns: options[:searchable_columns] || []
      }

      # manage default sort by parameter
      params["#{key}_sort_by"] = default_sort_by if params["#{key}_sort_by"].blank? && default_sort_by

      # manage sort by parameter
      unless params["#{key}_sort_by"].blank?
        sort_by_splitted = params["#{key}_sort_by"].split('|')
        sort_by_column = sort_by_splitted.first
        sort_by_order = sort_by_splitted.last

        if collection.respond_to?(:lato_index_order)
          collection = collection.lato_index_order(sort_by_column.to_sym, sort_by_order.to_sym)
        else
          collection = collection.order("#{sort_by_column} #{sort_by_order}")
        end
      end

      # manage search by parameter
      unless params["#{key}_search"].blank?
        search = params["#{key}_search"].to_s
        if collection.respond_to?(:lato_index_search)
          collection = collection.lato_index_search(search)
        else
          query_parts = @_lato_index[key][:searchable_columns].map do |column_name|
            # Sanitize column name per prevenire SQL injection
            sanitized_column = collection.quote_column_name(column_name)
            column_type = collection.column_for_attribute(column_name).type
            
            case column_type
            when :string, :text
              "LOWER(#{sanitized_column}) LIKE :search"
            when :integer, :decimal, :float
              "CAST(#{sanitized_column} AS TEXT) LIKE :search"
            else
              "CAST(#{sanitized_column} AS TEXT) LIKE :search"
            end
          end
          
          collection = collection.where(
            query_parts.join(' OR '), 
            search: "%#{search.downcase.strip}%"
          )
        end
      end

      # manage pagination
      if pagination || params["#{key}_page"] || params["#{key}_per_page"]
        page = params["#{key}_page"]&.to_i || 1
        per_page = params["#{key}_per_page"]&.to_i || (pagination.is_a?(Integer) ? pagination : 25)
        per_page = 100 if per_page > 100
        collection = collection.page(page).per(per_page)
      end

      collection
    end
  end
end
