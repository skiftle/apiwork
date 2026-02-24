# frozen_string_literal: true

class CreateFunnySnakeTables < ActiveRecord::Migration[8.1]
  def change
    create_table :funny_snake_invoices, id: :string do |t|
      t.string :number, null: false
      t.date :issued_on
      t.integer :status, default: 0, null: false
      t.string :notes

      t.timestamps
    end
  end
end
