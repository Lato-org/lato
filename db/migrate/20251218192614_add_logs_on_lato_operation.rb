class AddLogsOnLatoOperation < ActiveRecord::Migration[7.1]
  def change
    add_column :lato_operations, :logs, :json
  end
end
