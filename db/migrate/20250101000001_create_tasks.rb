class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string  :title,       null: false
      t.text    :description
      t.string  :status,      null: false, default: "todo"

      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, :created_at
  end
end
