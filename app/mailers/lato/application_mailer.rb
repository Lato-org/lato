module Lato
  class ApplicationMailer < ActionMailer::Base
    default from: Lato.config.email_from
    layout 'lato/mailer'
  end
end
