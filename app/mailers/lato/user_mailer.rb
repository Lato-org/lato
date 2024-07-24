module Lato
  class UserMailer < ApplicationMailer
    def email_verification_mail(user_id, code)
      @user = Lato::User.find(user_id)
      @code = code

      set_user_locale

      mail(
        to: @user.email,
        subject: I18n.t('lato.user_mailer.email_verification_mail_subject'),
        template_path: 'lato/mailer/user'
      )
    end

    def password_update_mail(user_id, code)
      @user = Lato::User.find(user_id)
      @code = code

      set_user_locale

      mail(
        to: @user.email,
        subject: I18n.t('lato.user_mailer.password_update_mail_subject'),
        template_path: 'lato/mailer/user'
      )
    end

    def signin_success_mail(user_id, ip_address)
      @user = Lato::User.find(user_id)
      @ip_address = ip_address

      set_user_locale

      mail(
        to: @user.email,
        subject: I18n.t('lato.user_mailer.signin_success_mail_subject'),
        template_path: 'lato/mailer/user'
      )
    end

    private

    def set_user_locale
      I18n.locale = @user.locale || I18n.default_locale
    end
  end
end
