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

ActiveRecord::Schema[7.0].define(version: 2022_11_18_072130) do
  create_table "lato_jobs", force: :cascade do |t|
    t.string "active_job_name"
    t.integer "status"
    t.integer "lato_user_id"
    t.datetime "closed_at"
    t.json "input"
    t.json "output"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lato_user_id"], name: "index_lato_jobs_on_lato_user_id"
  end

  create_table "lato_operations", force: :cascade do |t|
    t.string "active_job_name"
    t.json "active_job_input"
    t.json "active_job_output"
    t.integer "status"
    t.datetime "closed_at"
    t.integer "lato_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lato_user_id"], name: "index_lato_operations_on_lato_user_id"
  end

  create_table "lato_users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "email_verified_at"
    t.string "password_digest"
    t.integer "accepted_privacy_policy_version"
    t.integer "accepted_terms_and_conditions_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "code"
    t.integer "status"
    t.integer "lato_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lato_user_id"], name: "index_products_on_lato_user_id"
  end

  add_foreign_key "lato_jobs", "lato_users"
  add_foreign_key "lato_operations", "lato_users"
  add_foreign_key "products", "lato_users"
end
