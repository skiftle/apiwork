# frozen_string_literal: true

class CreateSteadyHorseTables < ActiveRecord::Migration[8.1]
  def change
    create_table :steady_horse_products, id: :string do |t|
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :category, null: false
      t.timestamps
    end
  end
end
