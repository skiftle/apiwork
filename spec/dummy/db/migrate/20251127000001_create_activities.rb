# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities do |t|
      t.string :action, null: false
      t.string :target_type
      t.integer :target_id
      t.boolean :read, default: false

      t.timestamps
    end

    add_index :activities, :action
    add_index :activities, :read
  end
end
