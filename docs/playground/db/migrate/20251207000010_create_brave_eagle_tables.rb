# frozen_string_literal: true

class CreateBraveEagleTables < ActiveRecord::Migration[7.1]
  def change
    create_table :brave_eagle_tasks, id: :string do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, default: 'pending'
      t.string :priority, default: 'medium'
      t.datetime :due_date
      t.boolean :archived, default: false
      t.timestamps
    end
  end
end
