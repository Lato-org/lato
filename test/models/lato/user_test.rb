require "test_helper"

module Lato
  class UserTest < ActiveSupport::TestCase
    test "json serialization should not expose credentials and second factor secrets" do
      user = Lato::User.new(email: 'pippo@mail.com', password: 'Password1!', authenticator_secret: 'SECRET', webauthn_id: 'ID', webauthn_public_key: 'KEY')
      json = user.as_json(except: [:locale])

      assert_equal 'pippo@mail.com', json['email']
      Lato::User::SENSITIVE_ATTRIBUTES.each { |attribute| assert_not json.key?(attribute), "#{attribute} exposed" }
      assert_not json.key?('locale')
    end
  end
end
