module Lato
  class Log::UserSignup < ApplicationRecord
    # Relations
    ##

    belongs_to :lato_user, class_name: 'Lato::User', foreign_key: :lato_user_id, optional: true

    # Hooks
    ##

    before_destroy do
      throw :abort
    end
  end
end
