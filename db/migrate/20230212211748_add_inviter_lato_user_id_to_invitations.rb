class AddInviterLatoUserIdToInvitations < ActiveRecord::Migration[7.0]
  def change
    add_reference :lato_invitations, :inviter_lato_user, foreign_key: { to_table: :lato_users }
  end
end
