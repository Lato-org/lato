class AddAuthenticatorSecretToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :lato_users, :authenticator_secret, :string
  end
end
