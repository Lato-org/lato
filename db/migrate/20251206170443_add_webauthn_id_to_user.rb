class AddWebauthnIdToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :lato_users, :webauthn_id, :string
    add_column :lato_users, :webauthn_public_key, :text
  end
end
