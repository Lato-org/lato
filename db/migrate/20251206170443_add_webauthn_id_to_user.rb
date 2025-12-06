class AddWebauthnIdToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :lato_users, :webauthn_id, :string
    add_column :lato_users, :webauthn_public_key, :text
    add_column :lato_users, :webauthn_sign_count, :integer, default: 0, null: false
  end
end
