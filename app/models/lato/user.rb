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

    # Operations
    ##

    def signin(params)
      self.email = params[:email]

      user = Lato::User.find_by(email: params[:email])
      unless user
        errors.add(:email, 'non valido')
        return
      end

      unless user.authenticate(params[:password])
        errors.add(:password, 'non valida')
        return
      end

      self.id = user.id
      reload

      true
    end

  end
end
