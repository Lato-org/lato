module Lato
  module Log
    # This module is used to add log to the application.
    # Log are used to track user actions without sensitive data.
    # Log should not be destroyed.
    before_destroy do
      throw :abort
    end

    def self.table_name_prefix
      'lato_log_'
    end
  end
end
