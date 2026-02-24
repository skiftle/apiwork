# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.string :name
      t.string :email
      t.string :bio
      t.string :timezone
      t.string :external_id
      t.decimal :balance, precision: 10, scale: 2
      t.time :preferred_contact_time
      t.timestamps
    end
  end
end
