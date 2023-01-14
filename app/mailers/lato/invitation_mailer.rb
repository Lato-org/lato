module Lato
  class InvitationMailer < ApplicationMailer
    def invite_mail(invitation_id)
      @invitation = Lato::Invitation.find(invitation_id)

      set_invitation_locale

      mail(
        to: @invitation.email,
        subject: 'Hai ricevuto un invito',
        template_path: 'lato/mailer/invitation'
      )
    end

    private

    def set_invitation_locale
      I18n.locale = @invitation.lato_user&.locale || I18n.default_locale
    end
  end
end
