# frozen_string_literal: true

class CreateSharpHawkTables < ActiveRecord::Migration[8.1]
  def change
    create_table :sharp_hawk_accounts, id: :string do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.string :role, default: 'member', null: false
      t.boolean :verified, default: false, null: false
      t.timestamps
    end
  end
end
