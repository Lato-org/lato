# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
require "rails/test_help"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_paths << File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_paths << File.expand_path("fixtures", __dir__)
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_paths.first + "/files"
  ActiveSupport::TestCase.fixtures :all
end

# Add helpers on ActionDispatch::IntegrationTest
class ActionDispatch::IntegrationTest
  def setup_lato_user
    Lato::User.create!(
      first_name: 'Pippo',
      last_name: 'Franco',
      email: 'pippo.franco@mail.com',
      email_verified_at: Time.now,
      password_digest: BCrypt::Password.create('Password1!'),
      accepted_privacy_policy_version: Lato.config.legal_privacy_policy_version,
      accepted_terms_and_conditions_version: Lato.config.legal_terms_and_conditions_version,
    )
  end

  def setup_lato_operation(user_id)
    Lato::Operation.create!(
      active_job_name: 'TestJob',
      active_job_input: {},
      status: :created,
      percentage: 0,
      lato_user_id: user_id
    )
  end

  def setup_lato_invitation
    Lato::Invitation.create!(
      email: 'pippo.franco.invitation@mail.com',
      accepted_code: '1234'
    )
  end

  protected def authenticate_user(user = nil, password = 'Password1!')
    user ||= @user

    post lato.authentication_signin_action_url, params: { user: {
      email: user.email,
      password: password
    } }
  end
end
