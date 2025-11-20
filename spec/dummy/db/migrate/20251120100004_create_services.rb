# frozen_string_literal: true

class CreateServices < ActiveRecord::Migration[7.0]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.text :description
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
