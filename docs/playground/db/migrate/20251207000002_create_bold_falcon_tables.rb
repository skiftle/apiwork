# frozen_string_literal: true

class CreateBoldFalconTables < ActiveRecord::Migration[7.1]
  def change
    create_table :bold_falcon_categories, id: :string do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.timestamps
    end

    create_table :bold_falcon_articles, id: :string do |t|
      t.references :category, foreign_key: { to_table: :bold_falcon_categories }, type: :string
      t.string :title, null: false
      t.text :body
      t.integer :status, default: 0, null: false
      t.integer :view_count, default: 0
      t.decimal :rating, precision: 3, scale: 2
      t.date :published_on
      t.timestamps
    end
  end
end
