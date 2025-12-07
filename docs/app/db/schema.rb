# frozen_string_literal: true

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

ActiveRecord::Schema[8.1].define(version: 20_251_207_000_011) do
  # Could not dump table "bold_falcon_articles" because of following StandardError
  #   Unknown type 'uuid' for column 'category_id'

  # Could not dump table "bold_falcon_categories" because of following StandardError
  #   Unknown type 'uuid' for column 'id'

  create_table 'brave_eagle_comments', id: :string, force: :cascade do |t|
    t.string 'author_name'
    t.text 'body', null: false
    t.datetime 'created_at', null: false
    t.string 'task_id', null: false
    t.datetime 'updated_at', null: false
    t.index ['task_id'], name: 'index_brave_eagle_comments_on_task_id'
  end

  create_table 'brave_eagle_tasks', id: :string, force: :cascade do |t|
    t.boolean 'archived', default: false
    t.string 'assignee_id'
    t.datetime 'created_at', null: false
    t.text 'description'
    t.datetime 'due_date'
    t.string 'priority', default: 'medium'
    t.string 'status', default: 'pending'
    t.string 'title', null: false
    t.datetime 'updated_at', null: false
    t.index ['assignee_id'], name: 'index_brave_eagle_tasks_on_assignee_id'
  end

  create_table 'brave_eagle_users', id: :string, force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'email', null: false
    t.string 'name', null: false
    t.datetime 'updated_at', null: false
  end

  # Could not dump table "clever_rabbit_line_items" because of following StandardError
  #   Unknown type 'uuid' for column 'id'

  # Could not dump table "clever_rabbit_orders" because of following StandardError
  #   Unknown type 'uuid' for column 'id'

  # Could not dump table "clever_rabbit_shipping_addresses" because of following StandardError
  #   Unknown type 'uuid' for column 'id'

  create_table 'eager_lion_customers', id: :string, force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'name', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'eager_lion_invoices', id: :string, force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'customer_id', null: false
    t.date 'issued_on'
    t.string 'notes'
    t.string 'number', null: false
    t.string 'status'
    t.datetime 'updated_at', null: false
  end

  create_table 'eager_lion_lines', id: :string, force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'description'
    t.string 'invoice_id', null: false
    t.decimal 'price', precision: 10, scale: 2
    t.integer 'quantity'
    t.datetime 'updated_at', null: false
  end

  create_table 'funny_snake_invoices', id: :string, force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.date 'issued_on'
    t.string 'notes'
    t.string 'number', null: false
    t.string 'status'
    t.datetime 'updated_at', null: false
  end

  # Could not dump table "gentle_owl_comments" because of following StandardError
  #   Unknown type 'uuid' for column 'commentable_id'

  # Could not dump table "gentle_owl_images" because of following StandardError
  #   Unknown type 'uuid' for column 'id'

  # Could not dump table "gentle_owl_posts" because of following StandardError
  #   Unknown type 'uuid' for column 'id'

  # Could not dump table "gentle_owl_videos" because of following StandardError
  #   Unknown type 'uuid' for column 'id'

  create_table 'grumpy_panda_activities', id: :string, force: :cascade do |t|
    t.string 'action', null: false
    t.datetime 'created_at', null: false
    t.datetime 'occurred_at'
    t.datetime 'updated_at', null: false
  end

  create_table 'happy_zebra_comments', id: :string, force: :cascade do |t|
    t.string 'author', null: false
    t.string 'body', null: false
    t.datetime 'created_at', null: false
    t.string 'post_id', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'happy_zebra_posts', id: :string, force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'title', null: false
    t.datetime 'updated_at', null: false
    t.string 'user_id', null: false
  end

  create_table 'happy_zebra_profiles', id: :string, force: :cascade do |t|
    t.text 'bio'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'user_id', null: false
    t.string 'website'
  end

  create_table 'happy_zebra_users', id: :string, force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'email', null: false
    t.datetime 'updated_at', null: false
    t.string 'username', null: false
    t.index ['email'], name: 'index_happy_zebra_users_on_email', unique: true
    t.index ['username'], name: 'index_happy_zebra_users_on_username', unique: true
  end

  create_table 'lazy_cow_posts', id: :string, force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'priority'
    t.string 'title', null: false
    t.datetime 'updated_at', null: false
  end

  # Could not dump table "mighty_wolf_vehicles" because of following StandardError
  #   Unknown type 'uuid' for column 'id'

  create_table 'swift_fox_contacts', id: :string, force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'email'
    t.string 'name', null: false
    t.string 'notes'
    t.string 'phone'
    t.datetime 'updated_at', null: false
  end

  create_table 'swift_fox_posts', force: :cascade do |t|
    t.text 'body'
    t.datetime 'created_at', null: false
    t.string 'status', default: 'draft'
    t.string 'title', null: false
    t.datetime 'updated_at', null: false
  end

  add_foreign_key 'bold_falcon_articles', 'bold_falcon_categories', column: 'category_id'
  add_foreign_key 'brave_eagle_comments', 'brave_eagle_tasks', column: 'task_id'
  add_foreign_key 'brave_eagle_tasks', 'brave_eagle_users', column: 'assignee_id'
  add_foreign_key 'clever_rabbit_line_items', 'clever_rabbit_orders', column: 'order_id'
  add_foreign_key 'clever_rabbit_shipping_addresses', 'clever_rabbit_orders', column: 'order_id'
  add_foreign_key 'eager_lion_invoices', 'eager_lion_customers', column: 'customer_id'
  add_foreign_key 'eager_lion_lines', 'eager_lion_invoices', column: 'invoice_id'
  add_foreign_key 'happy_zebra_comments', 'happy_zebra_posts', column: 'post_id'
  add_foreign_key 'happy_zebra_posts', 'happy_zebra_users', column: 'user_id'
  add_foreign_key 'happy_zebra_profiles', 'happy_zebra_users', column: 'user_id'
end
