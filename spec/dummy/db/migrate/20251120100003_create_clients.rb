# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients do |t|
      t.string :type, null: false # STI discriminator
      t.string :name, null: false
      t.string :email

      # PersonClient fields
      t.date :birth_date

      # CompanyClient fields
      t.string :industry
      t.string :registration_number

      t.timestamps
    end

    add_index :clients, :type
  end
end
