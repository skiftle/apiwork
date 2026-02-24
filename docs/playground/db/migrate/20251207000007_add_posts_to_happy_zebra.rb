# frozen_string_literal: true

class AddPostsToHappyZebra < ActiveRecord::Migration[8.1]
  def change
    create_table :happy_zebra_posts, id: :string do |t|
      t.string :user_id, null: false
      t.string :title, null: false

      t.timestamps
    end

    create_table :happy_zebra_comments, id: :string do |t|
      t.string :post_id, null: false
      t.string :body, null: false
      t.string :author, null: false

      t.timestamps
    end

    add_foreign_key :happy_zebra_posts, :happy_zebra_users, column: :user_id
    add_foreign_key :happy_zebra_comments, :happy_zebra_posts, column: :post_id
  end
end
