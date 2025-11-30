# frozen_string_literal: true

class CreateEagerLionTables < ActiveRecord::Migration[8.1]
  def change
    create_table :eager_lion_customers, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :eager_lion_invoices, id: :uuid do |t|
      t.references :customer, type: :uuid, null: false, foreign_key: { to_table: :eager_lion_customers }
      t.string :number, null: false
      t.date :issued_on
      t.string :notes
      t.string :status

      t.timestamps
    end

    create_table :eager_lion_lines, id: :uuid do |t|
      t.references :invoice, type: :uuid, null: false, foreign_key: { to_table: :eager_lion_invoices }
      t.string :description
      t.integer :quantity
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
