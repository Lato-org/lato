module Lato
  class Invitation < ApplicationRecord
    attr_accessor :actions

    # Validations
    ##

    validates :email, presence: true, uniqueness: true

    # Relations
    ##

    belongs_to :lato_user, class_name: 'Lato::User', foreign_key: :lato_user_id, optional: true
    belongs_to :inviter_lato_user, class_name: 'Lato::User', foreign_key: :inviter_lato_user_id, optional: true

    # Hooks
    ##

    before_validation do
      self.email = email&.downcase&.strip
    end

    # be sure that email is not already used by another user
    before_create do
      if Lato::User.find_by(email: email)
        errors.add(:email, 'is already used by another user')
        throw :abort
      end
    end

    # generate a random code for the invitation
    before_create do
      self.accepted_code = SecureRandom.hex(16)
    end

    # send an email to the invited user
    after_create do
      send_invite
    end

    # be sure accepted invitations can not be deleted
    before_destroy do
      throw :abort if accepted?
    end

    # Helpers
    ##

    def accepted?
      !!accepted_at
    end

    # Operations
    ##

    def send_invite
      if accepted?
        errors.add(:base, :already_accepted)
        return false
      end

      if c_email_invite_semaphore
        errors.add(:base, :email_sending_limit)
        return false
      end

      delivery = Lato::InvitationMailer.invite_mail(id).deliver_now
      unless delivery
        errors.add(:base, :email_sending_error)
        return false
      end

      c_email_invite_semaphore(true)

      true
    end


    # Cache
    ##

    def c_email_invite_semaphore(value = nil)
      cache_key = "Lato::Invitation/c_email_invite_semaphore/#{id}"
      return Rails.cache.read(cache_key) if value.nil?

      Rails.cache.write(cache_key, value, expires_in: 2.minutes)
      value
    end
  end
end
