class AddSecondFactorCountersToLatoUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :lato_users, :authenticator_last_used_at, :datetime
    add_column :lato_users, :webauthn_sign_count, :integer, null: false, default: 0
  end
end
