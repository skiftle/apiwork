# frozen_string_literal: true

class CreateSwiftFoxTables < ActiveRecord::Migration[8.0]
  def change
    create_table :swift_fox_posts do |t|
      t.string :title, null: false
      t.text :body
      t.string :status, default: 'draft'
      t.timestamps
    end
  end
end
