class CreateLatoInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :lato_invitations do |t|
      t.string :email
      t.datetime :accepted_at
      t.string :accepted_code
      t.references :lato_user, index: true, foreign_key: true
      t.timestamps
    end
  end
end
