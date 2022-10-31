module Lato
  class User < ApplicationRecord
    has_secure_password

    # Kredis
    ##

    kredis_boolean :email_verification_semaphore, expires_in: 2.minutes
    kredis_string :email_verification_code, expires_in: 30.minutes

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

    before_save do
      self.email_verified_at = nil if email_changed?
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

    def request_verify_email
      if email_verification_semaphore.value
        errors.add(:base, 'Attendi almeno 2 minuti per provare un nuovo tentativo di verifica email')
        return
      end

      code = SecureRandom.hex
      delivery = Lato::UserMailer.email_verification_mail(id, code).deliver_now
      unless delivery
        errors.add(:base, 'Impossibile inviare mail')
        return
      end

      email_verification_code.value = code
      email_verification_semaphore.value = true

      true
    end

    def verify_email(params)
      unless email_verification_code.value
        errors.add(:base, 'Il codice di verifica email risulta scaduto')
        return
      end

      unless email_verification_code.value == params[:code]
        errors.add(:base, 'Il codice di verifica email non risulta valido')
        return
      end

      email_verification_code.value = nil
      email_verification_semaphore.value = nil

      update_column(:email_verified_at, Time.now)
      true
    end
  end
end
