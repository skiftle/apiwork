# frozen_string_literal: true

class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :name, null: false
      t.string :description
      t.timestamps
    end
  end
end
