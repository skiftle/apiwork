# frozen_string_literal: true

class CreateNimbleGeckoTables < ActiveRecord::Migration[8.1]
  def change
    create_table :nimble_gecko_meal_plans, id: :string do |t|
      t.string :title, null: false
      t.integer :cook_time
      t.integer :serving_size
      t.timestamps
    end

    create_table :nimble_gecko_cooking_steps, id: :string do |t|
      t.string :meal_plan_id, null: false
      t.integer :step_number, null: false
      t.string :instruction, null: false
      t.integer :duration_minutes
      t.timestamps
    end

    add_foreign_key :nimble_gecko_cooking_steps, :nimble_gecko_meal_plans, column: :meal_plan_id
  end
end
