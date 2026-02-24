# frozen_string_literal: true

class CreateCalmTurtleTables < ActiveRecord::Migration[8.1]
  def change
    create_table :calm_turtle_customers, id: :string do |t|
      t.string :name, null: false
      t.string :billing_street
      t.string :billing_city
      t.string :billing_country
      t.timestamps
    end

    create_table :calm_turtle_orders, id: :string do |t|
      t.string :customer_id, null: false
      t.string :order_number, null: false
      t.string :shipping_street
      t.string :shipping_city
      t.string :shipping_country
      t.timestamps
    end

    add_foreign_key :calm_turtle_orders, :calm_turtle_customers, column: :customer_id
  end
end
