require "test_helper"
require "webauthn/fake_client"
require "minitest/mock"
require "net/http"
require "eth"

module Lato
  class SecurityHardeningTest < ActionDispatch::IntegrationTest
    setup do
      Rails.cache.clear
      @user = setup_lato_user
      @config = {
        authenticator_connection: Lato.config.authenticator_connection,
        web3_connection: Lato.config.web3_connection,
        hcaptcha_site_key: Lato.config.hcaptcha_site_key,
        hcaptcha_secret: Lato.config.hcaptcha_secret
      }
    end

    teardown do
      @config.each { |key, value| Lato.config.public_send("#{key}=", value) }
    end

    # Rate limiting
    ##

    test "per-ip limit allows exactly the configured number of requests" do
      10.times do
        post lato.authentication_signin_action_url, params: { user: { email: "unknown@mail.com", password: "wrong" } }
        assert_response :unprocessable_entity
      end
      post lato.authentication_signin_action_url, params: { user: { email: "unknown@mail.com", password: "wrong" } }
      assert_response :too_many_requests
    end

    test "per-account limit blocks password guessing from rotating ips" do
      10.times do |index|
        post lato.authentication_signin_action_url, params: { user: { email: @user.email, password: "wrong" } }, headers: { "REMOTE_ADDR" => "10.0.0.#{index}" }
        assert_response :unprocessable_entity
      end

      post lato.authentication_signin_action_url, params: { user: { email: @user.email.upcase, password: "Password1!" } }, headers: { "REMOTE_ADDR" => "10.0.1.1" }
      assert_response :too_many_requests
    end

    test "successful signin resets the per-account counter" do
      3.times { post lato.authentication_signin_action_url, params: { user: { email: @user.email, password: "wrong" } } }
      authenticate_user
      assert_equal 0, Rails.cache.read(account_limit_key(@user.email), raw: true).to_i
    end

    # Pending second factor
    ##

    test "authenticator action without pending state responds not found instead of error" do
      Lato.config.authenticator_connection = true
      post lato.authentication_authenticator_action_url(format: :json), params: { user: { authenticator_code: "123456" } }
      assert_response :not_found
    end

    test "pending second factor state expires" do
      enable_authenticator_and_signin
      travel 11.minutes do
        post lato.authentication_authenticator_action_url(format: :json), params: { user: { authenticator_code: ROTP::TOTP.new(@user.authenticator_secret).now } }
        assert_response :not_found
      end
    end

    test "pending second factor state is dropped after too many wrong codes" do
      enable_authenticator_and_signin
      5.times do
        post lato.authentication_authenticator_action_url(format: :json), params: { user: { authenticator_code: "000000" } }
        assert_response :unprocessable_entity
      end
      post lato.authentication_authenticator_action_url(format: :json), params: { user: { authenticator_code: ROTP::TOTP.new(@user.authenticator_secret).now } }
      assert_response :not_found
    end

    test "authenticator code can not be replayed" do
      enable_authenticator_and_signin
      code = ROTP::TOTP.new(@user.authenticator_secret).now
      post lato.authentication_authenticator_action_url, params: { user: { authenticator_code: code } }
      assert_redirected_to lato.root_path

      delete lato.authentication_signout_action_url
      post lato.authentication_signin_action_url, params: { user: { email: @user.email, password: "Password1!" } }
      post lato.authentication_authenticator_action_url(format: :json), params: { user: { authenticator_code: code } }
      assert_response :unprocessable_entity
    end

    # Password policy
    ##

    test "short passwords are rejected only when a password is set" do
      @user.password = @user.password_confirmation = "short"
      assert_not @user.valid?
      assert @user.errors.added?(:password, :too_short, count: Lato.config.auth_password_min_length)

      assert Lato::User.find(@user.id).update(first_name: "Other")
    end

    # Redirects
    ##

    test "switch locale ignores referer of another host" do
      post lato.switch_locale_url(locale: "it"), headers: { "HTTP_REFERER" => "https://evil.example.com/phish" }
      assert_redirected_to lato.root_path
    end

    test "switch locale goes back to same host referer" do
      post lato.switch_locale_url(locale: "it"), headers: { "HTTP_REFERER" => "http://www.example.com/lato/account" }
      assert_redirected_to "http://www.example.com/lato/account"
    end

    # hCaptcha
    ##

    test "hcaptcha network errors are reported as a validation error" do
      Lato.config.hcaptcha_site_key = "site"
      Lato.config.hcaptcha_secret = "secret"
      Net::HTTP.stub(:start, ->(*) { raise Net::OpenTimeout }) do
        post lato.authentication_signup_action_url(format: :json), params: { "h-captcha-response" => "token", user: { email: "new@mail.com" } }
      end
      assert_response :unprocessable_entity
      assert_includes JSON.parse(response.body)["base"], I18n.t("lato.hcaptcha_failed")
    end

    # Web3
    ##

    test "web3 signin message is bound to host, single use and expiring" do
      Lato.config.web3_connection = true
      key = Eth::Key.new
      @user.update!(web3_address: key.address.to_s)

      get lato.authentication_web3_signin_url
      message = css_select("#account_form-web3__nonce").text
      assert_includes message, "www.example.com wants you to sign in"
      assert_includes message, "Issued At:"

      signature = key.personal_sign(message)
      post lato.authentication_web3_signin_action_url, params: { user: { web3_address: key.address.to_s, web3_signed_nonce: signature } }
      assert_redirected_to lato.root_path

      delete lato.authentication_signout_action_url
      post lato.authentication_web3_signin_action_url, params: { user: { web3_address: key.address.to_s, web3_signed_nonce: signature } }
      assert_response :unprocessable_entity

      get lato.authentication_web3_signin_url
      message = css_select("#account_form-web3__nonce").text
      travel 6.minutes do
        post lato.authentication_web3_signin_action_url, params: { user: { web3_address: key.address.to_s, web3_signed_nonce: key.personal_sign(message) } }
        assert_response :unprocessable_entity
      end
    end

    test "web3 signin is not available with an active session" do
      Lato.config.web3_connection = true
      authenticate_user
      get lato.authentication_web3_signin_url
      assert_redirected_to lato.root_path
    end

    # WebAuthn
    ##

    test "webauthn sign count is stored and a non increasing counter is rejected" do
      original_origins = WebAuthn.configuration.allowed_origins
      WebAuthn.configuration.allowed_origins = ["http://www.example.com"]
      client = WebAuthn::FakeClient.new("http://www.example.com")
      options = @user.webauthn_registration_options
      assert @user.register_webauthn_credential(client.create(challenge: options.challenge).to_json, Base64.strict_encode64(options.challenge))

      options = @user.webauthn_authentication_options
      assert @user.webauthn_authentication({ webauthn_credential: client.get(challenge: options.challenge, sign_count: 5).to_json }, options.challenge)
      assert_equal 5, @user.reload.webauthn_sign_count

      options = @user.webauthn_authentication_options
      assert_not @user.webauthn_authentication({ webauthn_credential: client.get(challenge: options.challenge, sign_count: 5).to_json }, options.challenge)
    ensure
      WebAuthn.configuration.allowed_origins = original_origins
    end

    private

    def enable_authenticator_and_signin
      Lato.config.authenticator_connection = true
      @user.generate_authenticator_secret
      post lato.authentication_signin_action_url, params: { user: { email: @user.email, password: "Password1!" } }
      assert_redirected_to lato.authentication_authenticator_path
    end

    def account_limit_key(identifier)
      "Lato::Sessionable/account_limit/#{Digest::SHA256.hexdigest(identifier)}"
    end
  end
end
