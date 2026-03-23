# frozen_string_literal: true

class CreateCalmTurtleTables < ActiveRecord::Migration[8.1]
  def change
    create_table :calm_turtle_customers, id: :string do |t|
      t.string :name, null: false
      t.json :billing_address
      t.timestamps
    end

    create_table :calm_turtle_orders, id: :string do |t|
      t.string :order_number, null: false
      t.json :shipping_address
      t.timestamps
    end
  end
end
