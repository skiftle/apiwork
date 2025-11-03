# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.text :content, null: false
      t.string :author

      t.timestamps
    end
  end
end
