# frozen_string_literal: true

class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :type
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.json :metadata
      t.date :born_on
      t.string :industry
      t.string :registration_number
      t.timestamps
    end

    add_index :customers, :type
  end
end
