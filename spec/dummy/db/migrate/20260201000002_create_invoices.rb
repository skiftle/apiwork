# frozen_string_literal: true

class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :number, null: false
      t.integer :status, default: 0
      t.date :due_on
      t.text :notes
      t.json :metadata
      t.boolean :sent, default: false
      t.timestamps
    end
  end
end
