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

ActiveRecord::Schema[8.1].define(version: 2026_02_01_000012) do
  create_table "activities", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.boolean "read", default: false
    t.bigint "target_id"
    t.string "target_type"
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_activities_on_action"
    t.index ["read"], name: "index_activities_on_read"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.string "street"
    t.datetime "updated_at", null: false
    t.string "zip"
    t.index ["customer_id"], name: "index_addresses_on_customer_id"
  end

  create_table "adjustments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.integer "item_id", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_adjustments_on_item_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.integer "invoice_id", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_attachments_on_invoice_id"
  end

  create_table "customers", force: :cascade do |t|
    t.date "born_on"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "industry"
    t.json "metadata"
    t.string "name", null: false
    t.string "phone"
    t.string "registration_number"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_customers_on_type"
  end

  create_table "invoices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.date "due_on"
    t.json "metadata"
    t.text "notes"
    t.string "number", null: false
    t.boolean "sent", default: false
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
  end

  create_table "items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.integer "invoice_id", null: false
    t.integer "quantity", default: 1
    t.decimal "unit_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_items_on_invoice_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.integer "invoice_id", null: false
    t.integer "method", default: 0
    t.datetime "paid_at"
    t.string "reference"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_payments_on_customer_id"
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.decimal "balance", precision: 10, scale: 2
    t.string "bio"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "external_id"
    t.string "name"
    t.time "preferred_contact_time"
    t.string "timezone"
    t.datetime "updated_at", null: false
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.string "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_services_on_customer_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "tag_id", null: false
    t.bigint "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id", "taggable_type", "taggable_id"], name: "index_taggings_uniqueness", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "addresses", "customers"
  add_foreign_key "adjustments", "items"
  add_foreign_key "attachments", "invoices"
  add_foreign_key "invoices", "customers"
  add_foreign_key "items", "invoices"
  add_foreign_key "payments", "customers"
  add_foreign_key "payments", "invoices"
  add_foreign_key "services", "customers"
  add_foreign_key "taggings", "tags"
end
