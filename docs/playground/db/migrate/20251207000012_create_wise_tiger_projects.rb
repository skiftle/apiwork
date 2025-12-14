# frozen_string_literal: true

class CreateWiseTigerProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :wise_tiger_projects, id: :string do |t|
      t.string :name, null: false
      t.text :description
      t.string :status, default: 'active'
      t.string :priority, default: 'medium'
      t.date :deadline

      t.timestamps
    end
  end
end
