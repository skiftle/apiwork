# frozen_string_literal: true

class CreateBoldFalconTables < ActiveRecord::Migration[7.1]
  def change
    create_table :bold_falcon_categories, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.timestamps
    end

    create_table :bold_falcon_articles, id: :uuid do |t|
      t.references :category, type: :uuid, foreign_key: { to_table: :bold_falcon_categories }
      t.string :title, null: false
      t.text :body
      t.string :status, default: 'draft'
      t.integer :view_count, default: 0
      t.decimal :rating, precision: 3, scale: 2
      t.date :published_on
      t.timestamps
    end
  end
end
