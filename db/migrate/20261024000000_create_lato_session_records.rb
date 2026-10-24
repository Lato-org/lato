class CreateLatoSessionRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :lato_session_records do |t|
      t.references :lato_user, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.string :security_grant_action
      t.datetime :security_grant_expires_at
      t.string :security_challenge
      t.datetime :security_challenge_expires_at
      t.timestamps
    end
    add_index :lato_session_records, :token_digest, unique: true
    add_index :lato_session_records, :expires_at
  end
end
