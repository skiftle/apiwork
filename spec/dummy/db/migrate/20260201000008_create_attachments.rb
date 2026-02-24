# frozen_string_literal: true

class CreateAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :attachments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.string :filename, null: false
      t.timestamps
    end
  end
end
