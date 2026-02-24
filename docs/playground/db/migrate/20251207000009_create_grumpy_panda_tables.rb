# frozen_string_literal: true

class CreateGrumpyPandaTables < ActiveRecord::Migration[7.1]
  def change
    create_table :grumpy_panda_activities, id: :string do |t|
      t.string :action, null: false
      t.datetime :occurred_at
      t.timestamps
    end
  end
end
