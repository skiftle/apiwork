class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name
      t.integer :status, default: 0, null: false
      t.integer :first_day_of_week, default: 1

      t.timestamps
    end
  end
end