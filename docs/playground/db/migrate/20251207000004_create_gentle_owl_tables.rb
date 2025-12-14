# frozen_string_literal: true

class CreateGentleOwlTables < ActiveRecord::Migration[7.1]
  def change
    create_table :gentle_owl_posts, id: :uuid do |t|
      t.string :title, null: false
      t.text :body
      t.timestamps
    end

    create_table :gentle_owl_videos, id: :uuid do |t|
      t.string :title, null: false
      t.string :url, null: false
      t.integer :duration
      t.timestamps
    end

    create_table :gentle_owl_images, id: :uuid do |t|
      t.string :title, null: false
      t.string :url, null: false
      t.integer :width
      t.integer :height
      t.timestamps
    end

    create_table :gentle_owl_comments, id: :uuid do |t|
      t.references :commentable, type: :uuid, polymorphic: true, null: false
      t.text :body, null: false
      t.string :author_name
      t.timestamps
    end
  end
end
