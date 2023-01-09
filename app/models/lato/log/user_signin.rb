module Lato
  class Log::UserSignin < ApplicationRecord
    # Relations
    ##

    belongs_to :lato_user, class_name: 'Lato::User', foreign_key: :lato_user_id, optional: true
  end
end
