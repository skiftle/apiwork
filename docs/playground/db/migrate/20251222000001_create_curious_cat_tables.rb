# frozen_string_literal: true

class CreateCuriousCatTables < ActiveRecord::Migration[8.1]
  def change
    create_table :curious_cat_profiles, id: :string do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.json :settings, null: false, default: {}
      t.json :tags, null: false, default: []
      t.json :addresses, null: false, default: []
      t.json :preferences, null: false, default: {}
      t.json :metadata, null: false, default: {}
      t.timestamps
    end
  end
end
