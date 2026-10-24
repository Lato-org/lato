module Lato
  class SessionRecord < ApplicationRecord
    belongs_to :user, class_name: "Lato::User", foreign_key: :lato_user_id
  end
end
