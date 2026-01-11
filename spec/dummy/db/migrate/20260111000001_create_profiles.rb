# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :bio
      t.string :avatar_url
      t.string :timezone, default: 'UTC'
      t.string :external_id
      t.decimal :balance, precision: 10, scale: 2
      t.time :preferred_contact_time

      t.timestamps
    end
  end
end
