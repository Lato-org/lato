class CreateLatoLogUserSignups < ActiveRecord::Migration[7.0]
  def change
    create_table :lato_log_user_signups do |t|
      t.string :ip_address
      t.string :user_agent
      t.references :lato_user, index: true, foreign_key: true
      t.timestamps
    end
  end
end
