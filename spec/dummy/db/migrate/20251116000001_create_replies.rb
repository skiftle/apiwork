# frozen_string_literal: true

class CreateReplies < ActiveRecord::Migration[7.1]
  def change
    create_table :replies do |t|
      t.references :comment, null: false, foreign_key: true
      t.text :content, null: false
      t.string :author, null: false

      t.timestamps
    end
  end
end
