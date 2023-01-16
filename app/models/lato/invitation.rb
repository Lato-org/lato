module Lato
  class Invitation < ApplicationRecord
    attr_accessor :actions

    # Kredis
    ##

    kredis_boolean :email_invite_semaphore, expires_in: 2.minutes

    # Validations
    ##

    validates :email, presence: true, uniqueness: true

    # Relations
    ##

    belongs_to :lato_user, class_name: 'Lato::User', foreign_key: :lato_user_id, optional: true

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

      if email_invite_semaphore.value
        errors.add(:base, :email_sending_limit)
        return false
      end

      delivery = Lato::InvitationMailer.invite_mail(id).deliver_now
      unless delivery
        errors.add(:base, :email_sending_error)
        return false
      end

      email_invite_semaphore.value = true

      true
    end
  end
end
