class AddLogsOnLatoOperation < ActiveRecord::Migration[8.1]
  def change
    add_column :lato_operations, :logs, :json
  end
end
