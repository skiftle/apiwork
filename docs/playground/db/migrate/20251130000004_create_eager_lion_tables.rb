# frozen_string_literal: true

class CreateEagerLionTables < ActiveRecord::Migration[8.1]
  def change
    create_table :eager_lion_customers, id: :string do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :eager_lion_invoices, id: :string do |t|
      t.string :customer_id, null: false
      t.string :number, null: false
      t.date :issued_on
      t.string :notes
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    create_table :eager_lion_lines, id: :string do |t|
      t.string :invoice_id, null: false
      t.string :description
      t.integer :quantity
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end

    add_foreign_key :eager_lion_invoices, :eager_lion_customers, column: :customer_id
    add_foreign_key :eager_lion_lines, :eager_lion_invoices, column: :invoice_id
  end
end
