# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_01_000001) do
  create_table "eager_lion_customers", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "eager_lion_invoices", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "customer_id", null: false
    t.date "issued_on"
    t.string "notes"
    t.string "number", null: false
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "eager_lion_lines", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "invoice_id", null: false
    t.decimal "price", precision: 10, scale: 2
    t.integer "quantity"
    t.datetime "updated_at", null: false
  end

  create_table "lazy_cow_posts", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "priority"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "swift_fox_posts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "status", default: "draft"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "eager_lion_invoices", "eager_lion_customers", column: "customer_id"
  add_foreign_key "eager_lion_lines", "eager_lion_invoices", column: "invoice_id"
end
