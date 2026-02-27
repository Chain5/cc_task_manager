class AddUserIdToComments < ActiveRecord::Migration[8.1]
  def change
    add_reference :comments, :user, foreign_key: true, null: true
  end
end
