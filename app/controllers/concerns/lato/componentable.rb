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
        sort_by = parse_lato_index_sort_by(params["#{key}_sort_by"], @_lato_index[key][:sortable_columns])

        if sort_by && collection.respond_to?(:lato_index_order)
          collection = collection.lato_index_order(sort_by[:column].to_sym, sort_by[:order].to_sym)
        elsif sort_by
          collection = collection.order(sort_by[:column] => sort_by[:order])
        end
      end

      # manage search by parameter
      unless params["#{key}_search"].blank?
        search = params["#{key}_search"].to_s
        if collection.respond_to?(:lato_index_search)
          collection = collection.lato_index_search(search)
        else
          query = @_lato_index[key][:searchable_columns].map do |key|
            if collection.column_for_attribute(key).type == :string || collection.column_for_attribute(key).type == :text
              "LOWER(#{key}) LIKE :search"
            else
              "CAST(#{key} AS TEXT) LIKE :search"
            end
          end
          collection = collection.where(query.join(' OR '), search: "%#{search.downcase.strip}%")
        end
      end

      # manage pagination
      if pagination || params["#{key}_page"] || params["#{key}_per_page"]
        # Read from params or fallback to cookies, then to defaults
        page = params["#{key}_page"]&.to_i || 1
        per_page = params["#{key}_per_page"]&.to_i || cookies["lato_index_#{key}_per_page"]&.to_i || (pagination.is_a?(Integer) ? pagination : 25)
        per_page = 100 if per_page > 100
        
        # Save to cookies for persistence
        cookies["lato_index_#{key}_per_page"] = { value: per_page.to_s, expires: 1.year.from_now }
        
        collection = collection.page(page).per(per_page)
      end

      collection
    end

    private

    def parse_lato_index_sort_by(sort_by, sortable_columns)
      sort_by_column, sort_by_order = sort_by.to_s.split("|", 2)
      sort_by_column = sort_by_column.to_s
      sort_by_order = sort_by_order.to_s.downcase

      return unless sortable_columns.map(&:to_s).include?(sort_by_column)
      return unless %w[asc desc].include?(sort_by_order)

      { column: sort_by_column, order: sort_by_order }
    end
  end
end
