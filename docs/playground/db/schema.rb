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

ActiveRecord::Schema[8.1].define(version: 2025_12_22_000001) do
  create_table "bold_falcon_articles", id: :string, force: :cascade do |t|
    t.text "body"
    t.string "category_id"
    t.datetime "created_at", null: false
    t.date "published_on"
    t.decimal "rating", precision: 3, scale: 2
    t.string "status", default: "draft"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0
    t.index ["category_id"], name: "index_bold_falcon_articles_on_category_id"
  end

  create_table "bold_falcon_categories", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
  end

  create_table "brave_eagle_comments", id: :string, force: :cascade do |t|
    t.string "author_name"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.string "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_brave_eagle_comments_on_task_id"
  end

  create_table "brave_eagle_tasks", id: :string, force: :cascade do |t|
    t.boolean "archived", default: false
    t.string "assignee_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "due_date"
    t.string "priority", default: "medium"
    t.string "status", default: "pending"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_brave_eagle_tasks_on_assignee_id"
  end

  create_table "brave_eagle_users", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clever_rabbit_line_items", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "order_id", null: false
    t.string "product_name", null: false
    t.integer "quantity", default: 1
    t.decimal "unit_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_clever_rabbit_line_items_on_order_id"
  end

  create_table "clever_rabbit_orders", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "order_number", null: false
    t.string "status", default: "pending"
    t.decimal "total", precision: 10, scale: 2
    t.datetime "updated_at", null: false
  end

  create_table "clever_rabbit_shipping_addresses", id: :string, force: :cascade do |t|
    t.string "city", null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.string "order_id", null: false
    t.string "postal_code", null: false
    t.string "street", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_clever_rabbit_shipping_addresses_on_order_id"
  end

  create_table "curious_cat_profiles", id: :string, force: :cascade do |t|
    t.json "addresses", default: [], null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.json "metadata", default: {}, null: false
    t.string "name", null: false
    t.json "preferences", default: {}, null: false
    t.json "settings", default: {}, null: false
    t.json "tags", default: [], null: false
    t.datetime "updated_at", null: false
  end

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

  create_table "funny_snake_invoices", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "issued_on"
    t.string "notes"
    t.string "number", null: false
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "gentle_owl_comments", id: :string, force: :cascade do |t|
    t.string "author_name"
    t.text "body", null: false
    t.string "commentable_id", null: false
    t.string "commentable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_gentle_owl_comments_on_commentable"
  end

  create_table "gentle_owl_images", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "height"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.integer "width"
  end

  create_table "gentle_owl_posts", id: :string, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gentle_owl_videos", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
  end

  create_table "grumpy_panda_activities", id: :string, force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.datetime "occurred_at"
    t.datetime "updated_at", null: false
  end

  create_table "happy_zebra_comments", id: :string, force: :cascade do |t|
    t.string "author", null: false
    t.string "body", null: false
    t.datetime "created_at", null: false
    t.string "post_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "happy_zebra_posts", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "user_id", null: false
  end

  create_table "happy_zebra_profiles", id: :string, force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_id", null: false
    t.string "website"
  end

  create_table "happy_zebra_users", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_happy_zebra_users_on_email", unique: true
    t.index ["username"], name: "index_happy_zebra_users_on_username", unique: true
  end

  create_table "mighty_wolf_vehicles", id: :string, force: :cascade do |t|
    t.string "brand", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.integer "doors"
    t.integer "engine_cc"
    t.string "model", null: false
    t.decimal "payload_capacity", precision: 10, scale: 2
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
  end

  create_table "swift_fox_contacts", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.string "notes"
    t.string "phone"
    t.datetime "updated_at", null: false
  end

  create_table "wise_tiger_projects", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "deadline"
    t.text "description"
    t.string "name", null: false
    t.string "priority", default: "medium"
    t.string "status", default: "active"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bold_falcon_articles", "bold_falcon_categories", column: "category_id"
  add_foreign_key "brave_eagle_comments", "brave_eagle_tasks", column: "task_id"
  add_foreign_key "brave_eagle_tasks", "brave_eagle_users", column: "assignee_id"
  add_foreign_key "clever_rabbit_line_items", "clever_rabbit_orders", column: "order_id"
  add_foreign_key "clever_rabbit_shipping_addresses", "clever_rabbit_orders", column: "order_id"
  add_foreign_key "eager_lion_invoices", "eager_lion_customers", column: "customer_id"
  add_foreign_key "eager_lion_lines", "eager_lion_invoices", column: "invoice_id"
  add_foreign_key "happy_zebra_comments", "happy_zebra_posts", column: "post_id"
  add_foreign_key "happy_zebra_posts", "happy_zebra_users", column: "user_id"
  add_foreign_key "happy_zebra_profiles", "happy_zebra_users", column: "user_id"
end
