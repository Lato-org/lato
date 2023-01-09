module Lato
  class InvitationMailer < ApplicationMailer
    def invite_mail(invitation_id)
      @invitation = Lato::Invitation.find(invitation_id)
      mail(
        to: @invitation.email,
        subject: 'Hai ricevuto un invito',
        template_path: 'lato/mailer/invitation'
      )
    end
  end
end