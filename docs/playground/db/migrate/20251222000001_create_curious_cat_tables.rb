# frozen_string_literal: true

class CreateCuriousCatTables < ActiveRecord::Migration[8.1]
  def change
    create_table :curious_cat_profiles, id: :string do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.json :settings, null: false
      t.text :tags, null: false
      t.json :addresses, null: false
      t.json :preferences, null: false
      t.text :metadata, null: false
      t.timestamps
    end
  end
end
