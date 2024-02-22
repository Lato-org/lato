class AddWeb3ToLatoUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :lato_users, :web3_address, :string
    add_column :lato_users, :web3_nonce, :string
  end
end
