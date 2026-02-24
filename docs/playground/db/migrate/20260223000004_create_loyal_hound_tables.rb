# frozen_string_literal: true

class CreateLoyalHoundTables < ActiveRecord::Migration[8.1]
  def change
    create_table :loyal_hound_authors, id: :string do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :loyal_hound_books, id: :string do |t|
      t.string :title, null: false
      t.string :author_id, null: false
      t.date :published_on
      t.timestamps
    end

    create_table :loyal_hound_reviews, id: :string do |t|
      t.string :book_id, null: false
      t.integer :rating, null: false
      t.text :body
      t.timestamps
    end

    add_foreign_key :loyal_hound_books, :loyal_hound_authors, column: :author_id
    add_foreign_key :loyal_hound_reviews, :loyal_hound_books, column: :book_id
  end
end
