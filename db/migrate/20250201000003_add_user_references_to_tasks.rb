class AddUserReferencesToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :creator,  foreign_key: { to_table: :users }, null: true
    add_reference :tasks, :assignee, foreign_key: { to_table: :users }, null: true
  end
end
