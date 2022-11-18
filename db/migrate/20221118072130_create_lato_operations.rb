class CreateLatoOperations < ActiveRecord::Migration[7.0]
  def change
    create_table :lato_operations do |t|
      t.string :active_job_name
      t.json :active_job_input
      t.json :active_job_output
      t.integer :status
      t.integer :percentage, min: 0, max: 100
      t.datetime :closed_at
      t.references :lato_user, index: true, foreign_key: true
      t.timestamps
    end
  end
end
