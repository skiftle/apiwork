# frozen_string_literal: true

class ExtendBraveEagleTables < ActiveRecord::Migration[7.1]
  def change
    create_table :brave_eagle_users, id: :string do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.timestamps
    end

    create_table :brave_eagle_comments, id: :string do |t|
      t.references :task, foreign_key: { to_table: :brave_eagle_tasks }, null: false, type: :string
      t.text :body, null: false
      t.string :author_name
      t.timestamps
    end

    add_reference :brave_eagle_tasks, :assignee, foreign_key: { to_table: :brave_eagle_users }, type: :string
  end
end
