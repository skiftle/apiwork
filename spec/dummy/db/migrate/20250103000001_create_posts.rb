# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :body
      t.boolean :published, default: false

      t.timestamps
    end
  end
end
