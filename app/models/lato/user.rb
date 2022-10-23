module Lato
  class User < ApplicationRecord
    has_secure_password

    # Validations
    ##

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true, uniqueness: true

    # Hooks
    ##

    before_validation do
      self.email = email&.downcase&.strip
    end
  end
end
