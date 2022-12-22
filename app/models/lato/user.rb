module Lato
  class User < ApplicationRecord
    include LatoUserApplication

    has_secure_password

    # Kredis
    ##

    kredis_boolean :email_verification_semaphore, expires_in: 2.minutes
    kredis_string :email_verification_code, expires_in: 30.minutes
    kredis_string :password_update_code, expires_in: 30.minutes

    # Validations
    ##

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true, uniqueness: true
    validates :accepted_privacy_policy_version, presence: true
    validates :accepted_terms_and_conditions_version, presence: true

    # Relations
    ##

    has_many :lato_operations, class_name: 'Lato::Operation', foreign_key: :lato_user_id, dependent: :nullify

    # Hooks
    ##

    before_validation do
      self.email = email&.downcase&.strip
    end

    before_save do
      self.email_verified_at = nil if email_changed?
      self.accepted_privacy_policy_version = Lato.config.legal_privacy_policy_version if accepted_privacy_policy_version_changed?
      self.accepted_terms_and_conditions_version = Lato.config.legal_terms_and_conditions_version if accepted_terms_and_conditions_version_changed?
    end

    # Questions
    ##

    def valid_accepted_privacy_policy_version?
      @valid_accepted_privacy_policy_version ||= accepted_privacy_policy_version >= Lato.config.legal_privacy_policy_version
    end

    def valid_accepted_terms_and_conditions_version?
      @valid_accepted_terms_and_conditions_version ||= accepted_terms_and_conditions_version >= Lato.config.legal_terms_and_conditions_version
    end

    # Helpers
    ##

    def full_name
      "#{last_name} #{first_name}"
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

      code = SecureRandom.hex.upcase
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

    def destroy_with_confirmation(params)
      unless params[:email_confirmation] == email
        errors.add(:email, :not_correct)
        return
      end

      destroy
    end

    def request_recover_password(params)
      user = Lato::User.find_by(email: params[:email])
      unless user
        errors.add(:email, :not_registered)
        return
      end

      code = SecureRandom.hex.upcase
      delivery = Lato::UserMailer.password_update_mail(user.id, code).deliver_now
      unless delivery
        errors.add(:base, 'Impossibile inviare mail')
        return
      end

      self.id = user.id
      reload

      password_update_code.value = code

      true
    end

    def update_password(params)
      unless password_update_code.value
        errors.add(:base, 'Il codice di verifica risulta scaduto')
        return
      end

      unless password_update_code.value == params[:code]
        errors.add(:base, 'Il codice di verifica non risulta valido')
        return
      end

      password_update_code.value = nil

      update(params.permit(:password, :password_confirmation))
    end

    def update_accepted_privacy_policy_version(params)
      unless params[:confirm]
        errors.add(:base, 'Per accettare la privacy policy devi selezionare la checkbox di conferma')
        return
      end

      update(accepted_privacy_policy_version: Lato.config.legal_privacy_policy_version)
    end

    def update_accepted_terms_and_conditions_version(params)
      unless params[:confirm]
        errors.add(:base, 'Per accettare i termini e condizioni devi selezionare la checkbox di conferma')
        return
      end

      update(accepted_terms_and_conditions_version: Lato.config.legal_terms_and_conditions_version)
    end
  end
end
