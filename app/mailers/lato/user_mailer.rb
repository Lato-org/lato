module Lato
  class UserMailer < ApplicationMailer
    def email_verification_mail(user_id, code)
      @user = Lato::User.find(user_id)
      @code = code
      mail(
        to: @user.email,
        subject: 'Conferma il tuo indirizzo email',
        template_path: 'lato/mailer/user'
      )
    end
  end
end
