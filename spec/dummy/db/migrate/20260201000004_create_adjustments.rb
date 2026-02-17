# frozen_string_literal: true

class CreateAdjustments < ActiveRecord::Migration[8.1]
  def change
    create_table :adjustments do |t|
      t.references :item, null: false, foreign_key: true
      t.string :description, null: false
      t.decimal :amount, precision: 10, scale: 2
      t.timestamps
    end
  end
end
