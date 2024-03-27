module Lato
  class User < ApplicationRecord
    include Lato::DependencyHelper
    include LatoUserApplication

    has_secure_password

    # Validations
    ##

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true, uniqueness: true
    validates :accepted_privacy_policy_version, presence: true
    validates :accepted_terms_and_conditions_version, presence: true
    validates :web3_address, uniqueness: true, allow_blank: true

    # Relations
    ##

    has_many :lato_operations, class_name: 'Lato::Operation', foreign_key: :lato_user_id, dependent: :nullify
    has_many :lato_invitations, class_name: 'Lato::Invitation', foreign_key: :lato_user_id, dependent: :nullify
    has_many :lato_invitations_as_inviter, class_name: 'Lato::Invitation', foreign_key: :inviter_lato_user_id, dependent: :nullify

    has_many :lato_log_user_signins, class_name: 'Lato::Log::UserSignin', foreign_key: :lato_user_id, dependent: :nullify
    has_many :lato_log_user_signups, class_name: 'Lato::Log::UserSignup', foreign_key: :lato_user_id, dependent: :nullify

    # Hooks
    ##

    before_validation do
      self.email = email&.downcase&.strip
      self.web3_address = web3_address&.downcase&.strip
    end

    before_create do
      self.locale ||= I18n.default_locale
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

    def authenticator_enabled?
      !authenticator_secret.blank?
    end

    # Helpers
    ##

    def full_name
      "#{last_name} #{first_name}"
    end

    def gravatar_image_url(size = 200)
      @gravatar_image_url ||= "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=#{size}"
    end

    def authenticator_qr_code_base64(size = 200)
      "data:image/png;base64,#{Base64.strict_encode64(RQRCode::QRCode.new(ROTP::TOTP.new(authenticator_secret, :issuer => Lato.config.application_title).provisioning_uri(email).to_s).as_png(size: size, border_modules: 0).to_s)}"
    end

    # Operations
    ##

    def signup(params = {})
      return unless save

      begin
        lato_log_user_signups.create(
          ip_address: params[:ip_address],
          user_agent: params[:user_agent]
        )
      rescue StandardError => e
        Rails.logger.error(e)
      end

      true
    end

    def signin(params)
      self.email = params[:email]

      user = Lato::User.find_by(email: params[:email])
      unless user
        errors.add(:email, :not_correct)
        return
      end

      unless user.authenticate(params[:password])
        errors.add(:password, :not_correct)
        return
      end

      self.id = user.id
      reload

      begin
        lato_log_user_signins.create(
          ip_address: params[:ip_address],
          user_agent: params[:user_agent]
        )
      rescue StandardError => e
        Rails.logger.error(e)
      end

      true
    end

    def web3_signin(params)
      depends_on('eth')

      self.web3_address = params[:web3_address]

      user = Lato::User.find_by(web3_address: params[:web3_address].downcase)
      unless user
        errors.add(:web3_address, :not_correct)
        return
      end

      signature_pubkey = Eth::Signature.personal_recover(params[:web3_nonce], params[:web3_signed_nonce])
      signature_address = Eth::Util.public_key_to_address signature_pubkey
      unless signature_address.to_s.downcase == params[:web3_address].downcase
        errors.add(:web3_signed_nonce, :not_correct)
        return
      end

      self.id = user.id
      reload

      begin
        lato_log_user_signins.create(
          ip_address: params[:ip_address],
          user_agent: params[:user_agent]
        )
      rescue StandardError => e
        Rails.logger.error(e)
      end

      true
    rescue StandardError => e
      errors.add(:base, :web3_connection_error)
      false
    end

    def request_verify_email
      if c_email_verification_semaphore
        errors.add(:base, :email_verification_limit)
        return
      end

      code = SecureRandom.hex.upcase
      delivery = Lato::UserMailer.email_verification_mail(id, code).deliver_now
      unless delivery
        errors.add(:base, :email_sending_error)
        return
      end

      c_email_verification_code(code)
      c_email_verification_semaphore(true)

      true
    end

    def verify_email(params)
      email_verification_code = c_email_verification_code

      if email_verification_code.blank?
        errors.add(:base, :email_verification_code_expired)
        return
      end

      unless email_verification_code == params[:code]
        errors.add(:base, :email_verification_code_invalid)
        return
      end

      c_email_verification_code('')
      c_email_verification_semaphore(false)

      update_column(:email_verified_at, Time.now)
      true
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
        errors.add(:base, :email_sending_error)
        return
      end

      self.id = user.id
      reload

      c_password_update_code(code)

      true
    end

    def update_password(params)
      password_update_code = c_password_update_code

      if password_update_code.blank?
        errors.add(:base, :password_update_code_expired)
        return
      end

      unless password_update_code == params[:code]
        errors.add(:base, :password_update_code_invalid)
        return
      end

      c_password_update_code('')

      update(params.permit(:password, :password_confirmation).merge(
        authenticator_secret: nil # Reset authenticator secret when password is updated
      ))
    end

    def update_accepted_privacy_policy_version(params)
      unless params[:confirm]
        errors.add(:base, :privacy_policy_invalid)
        return
      end

      update(accepted_privacy_policy_version: Lato.config.legal_privacy_policy_version)
    end

    def update_accepted_terms_and_conditions_version(params)
      unless params[:confirm]
        errors.add(:base, :terms_and_conditions_invalid)
        return
      end

      update(accepted_terms_and_conditions_version: Lato.config.legal_terms_and_conditions_version)
    end

    def destroy_with_confirmation(params)
      unless params[:email_confirmation] == email
        errors.add(:email, :not_correct)
        return
      end

      destroy
    end

    def accept_invitation(params)
      invitation = Lato::Invitation.find_by(id: params[:id], accepted_code: params[:accepted_code])
      if !invitation || invitation.accepted? || invitation.email != email
        errors.add(:base, :invitation_invalid)
        return
      end

      ActiveRecord::Base.transaction do
        raise ActiveRecord::Rollback unless save && invitation.update(
          accepted_at: Time.now,
          lato_user_id: id
        )

        true
      end
    end

    def add_web3_connection(params)
      depends_on('eth')

      signature_pubkey = Eth::Signature.personal_recover(params[:web3_nonce], params[:web3_signed_nonce])
      signature_address = Eth::Util.public_key_to_address signature_pubkey
      unless signature_address.to_s.downcase == params[:web3_address].downcase
        errors.add(:base, :web3_address_invalid)
        return
      end

      update(web3_address: params[:web3_address])
    rescue StandardError => e
      errors.add(:base, :web3_connection_error)
      false
    end

    def remove_web3_connection
      update(web3_address: nil)
      true
    end

    def generate_authenticator_secret
      update(authenticator_secret: ROTP::Base32.random)
    end

    def authenticator(params)
      return false unless authenticator_enabled?

      totp = ROTP::TOTP.new(authenticator_secret)
      result = totp.verify(params[:authenticator_code])
      unless result
        errors.add(:base, :authenticator_code_invalid)
        return
      end

      true
    end

    # Cache
    ##

    def c_email_verification_semaphore(value = nil)
      cache_key = "Lato::User/c_email_verification_semaphore/#{id}"
      return Rails.cache.read(cache_key) if value.nil?

      Rails.cache.write(cache_key, value, expires_in: 2.minutes)
      value
    end

    def c_email_verification_code(value = nil)
      cache_key = "Lato::User/c_email_verification_code/#{id}"
      return Rails.cache.read(cache_key) if value.nil?

      Rails.cache.write(cache_key, value, expires_in: 30.minutes)
      value
    end

    def c_password_update_code(value = nil)
      cache_key = "Lato::User/c_password_update_code/#{id}"
      return Rails.cache.read(cache_key) if value.nil?

      Rails.cache.write(cache_key, value, expires_in: 30.minutes)
      value
    end
  end
end
