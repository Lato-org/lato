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

    def password_update_mail(user_id, code)
      @user = Lato::User.find(user_id)
      @code = code
      mail(
        to: @user.email,
        subject: 'Imposta una nuova password',
        template_path: 'lato/mailer/user'
      )
    end
  end
end
