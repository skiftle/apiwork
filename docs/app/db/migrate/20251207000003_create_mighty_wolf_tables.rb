# frozen_string_literal: true

class CreateMightyWolfTables < ActiveRecord::Migration[7.1]
  def change
    create_table :mighty_wolf_vehicles, id: :uuid do |t|
      t.string :type, null: false
      t.string :brand, null: false
      t.string :model, null: false
      t.integer :year
      t.string :color

      # Car-specific
      t.integer :doors

      # Motorcycle-specific
      t.integer :engine_cc

      # Truck-specific
      t.decimal :payload_capacity, precision: 10, scale: 2

      t.timestamps
    end
  end
end
