# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :street
      t.string :city
      t.string :zip
      t.string :country
      t.timestamps
    end
  end
end
