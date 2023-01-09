module Lato
  class Invitation < ApplicationRecord
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
      Lato::InvitationMailer.invite_mail(id).deliver_now
    end

    # Helpers
    ##

    def accepted?
      !!acepted_at
    end
  end
end
