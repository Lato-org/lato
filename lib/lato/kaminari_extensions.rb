# NOTE: Hard fix taken from https://gist.github.com/sononum/6183139 from kaminari issue https://github.com/search?q=repo%3Akaminari%2Fkaminari%20def%20total_count&type=code

module Kaminari
  module PageScopeMethods
    def total_count
      if ActiveRecord::Base.connection.adapter_name.downcase == "postgresql"
        @_hacked_total_count || (@_hacked_total_count = self.connection.execute("SELECT (reltuples)::integer FROM pg_class r WHERE relkind = 'r' AND relname ='#{table_name}'").first["reltuples"].to_i)
      else
        super
      end
    end
  end
end
