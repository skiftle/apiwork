class CreateAuthors < ActiveRecord::Migration[8.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.text :bio
      t.boolean :verified

      t.timestamps
    end
  end
end
