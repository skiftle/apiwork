# frozen_string_literal: true

class CreateAttachments < ActiveRecord::Migration[7.1]
  def change
    create_table :attachments do |t|
      t.references :post, null: false, foreign_key: true
      t.string :filename
      t.timestamps
    end
  end
end
