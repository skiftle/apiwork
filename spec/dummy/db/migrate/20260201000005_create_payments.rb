# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2
      t.integer :method, default: 0
      t.integer :status, default: 0
      t.string :reference
      t.datetime :paid_at
      t.timestamps
    end
  end
end
