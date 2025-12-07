# frozen_string_literal: true

class CreateSwiftFoxTables < ActiveRecord::Migration[8.1]
  def change
    create_table :swift_fox_contacts, id: :string do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.string :notes

      t.timestamps
    end
  end
end
