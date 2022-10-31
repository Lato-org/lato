class CreateLatoUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :lato_users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.datetime :email_verified_at
      t.string :password_digest
      t.integer :accepted_privacy_policy_version
      t.integer :accepted_terms_and_conditions_version
      t.timestamps
    end
  end
end
