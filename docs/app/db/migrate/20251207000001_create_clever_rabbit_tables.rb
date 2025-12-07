# frozen_string_literal: true

class CreateCleverRabbitTables < ActiveRecord::Migration[7.1]
  def change
    create_table :clever_rabbit_orders, id: :uuid do |t|
      t.string :order_number, null: false
      t.string :status, default: 'pending'
      t.decimal :total, precision: 10, scale: 2
      t.timestamps
    end

    create_table :clever_rabbit_line_items, id: :uuid do |t|
      t.references :order, type: :uuid, null: false, foreign_key: { to_table: :clever_rabbit_orders }
      t.string :product_name, null: false
      t.integer :quantity, default: 1
      t.decimal :unit_price, precision: 10, scale: 2
      t.timestamps
    end

    create_table :clever_rabbit_shipping_addresses, id: :uuid do |t|
      t.references :order, type: :uuid, null: false, foreign_key: { to_table: :clever_rabbit_orders }
      t.string :street, null: false
      t.string :city, null: false
      t.string :postal_code, null: false
      t.string :country, null: false
      t.timestamps
    end
  end
end
