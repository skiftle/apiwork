# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.string :action
      t.boolean :read, default: false
      t.string :target_type
      t.bigint :target_id
      t.timestamps
    end

    add_index :activities, :action
    add_index :activities, :read
  end
end
