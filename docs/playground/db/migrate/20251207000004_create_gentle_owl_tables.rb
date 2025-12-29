# frozen_string_literal: true

class CreateGentleOwlTables < ActiveRecord::Migration[7.1]
  def change
    create_table :gentle_owl_posts, id: :string do |t|
      t.string :title, null: false
      t.text :body
      t.timestamps
    end

    create_table :gentle_owl_videos, id: :string do |t|
      t.string :title, null: false
      t.string :url, null: false
      t.integer :duration
      t.timestamps
    end

    create_table :gentle_owl_images, id: :string do |t|
      t.string :title, null: false
      t.string :url, null: false
      t.integer :width
      t.integer :height
      t.timestamps
    end

    create_table :gentle_owl_comments, id: :string do |t|
      t.references :commentable, null: false, polymorphic: true, type: :string
      t.text :body, null: false
      t.string :author_name
      t.timestamps
    end
  end
end
