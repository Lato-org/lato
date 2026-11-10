require "test_helper"

module Lato
  class UserMailerTest < ActionMailer::TestCase
    setup do
      @user = Lato::User.create!(
        first_name: "Pippo", last_name: "Franco", email: "mailer@mail.com", password: "Password1!",
        accepted_privacy_policy_version: 1, accepted_terms_and_conditions_version: 1
      )
    end

    test "emails use the english template for english users" do
      @user.update!(locale: "en")
      assert_includes Lato::UserMailer.signin_success_mail(@user.id, "1.2.3.4").body.encoded, "An access to your"
    end

    test "emails use the italian template for italian users" do
      @user.update!(locale: "it")
      assert_not_includes Lato::UserMailer.signin_success_mail(@user.id, "1.2.3.4").body.encoded, "An access to your"
    end
  end
end
