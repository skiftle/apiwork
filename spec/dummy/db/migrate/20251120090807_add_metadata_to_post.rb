# frozen_string_literal: true

class AddMetadataToPost < ActiveRecord::Migration[8.1]
  def change
    # SQLite doesn't support jsonb, so we use text with JSON serialization
    # ActiveRecord will handle JSON serialization via serialize :metadata, coder: JSON
    add_column :posts, :metadata, :json
  end
end
