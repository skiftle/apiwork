# frozen_string_literal: true

class CreateHappyZebraTables < ActiveRecord::Migration[8.1]
  def change
    create_table :happy_zebra_users, id: :string do |t|
      t.string :email, null: false
      t.string :username, null: false

      t.timestamps
    end

    create_table :happy_zebra_profiles, id: :string do |t|
      t.string :user_id, null: false
      t.text :bio
      t.string :website

      t.timestamps
    end

    add_foreign_key :happy_zebra_profiles, :happy_zebra_users, column: :user_id
    add_index :happy_zebra_users, :email, unique: true
    add_index :happy_zebra_users, :username, unique: true
  end
end
