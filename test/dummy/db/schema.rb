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

ActiveRecord::Schema[8.1].define(version: 2025_12_06_170443) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "lato_invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.string "accepted_code"
    t.datetime "created_at", null: false
    t.string "email"
    t.integer "inviter_lato_user_id"
    t.integer "lato_user_id"
    t.datetime "updated_at", null: false
    t.index ["inviter_lato_user_id"], name: "index_lato_invitations_on_inviter_lato_user_id"
    t.index ["lato_user_id"], name: "index_lato_invitations_on_lato_user_id"
  end

  create_table "lato_log_user_signins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.integer "lato_user_id"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["lato_user_id"], name: "index_lato_log_user_signins_on_lato_user_id"
  end

  create_table "lato_log_user_signups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.integer "lato_user_id"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["lato_user_id"], name: "index_lato_log_user_signups_on_lato_user_id"
  end

  create_table "lato_operations", force: :cascade do |t|
    t.json "active_job_input"
    t.string "active_job_name"
    t.json "active_job_output"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.integer "lato_user_id"
    t.integer "percentage"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["lato_user_id"], name: "index_lato_operations_on_lato_user_id"
  end

  create_table "lato_users", force: :cascade do |t|
    t.integer "accepted_privacy_policy_version"
    t.integer "accepted_terms_and_conditions_version"
    t.string "authenticator_secret"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "email_verified_at"
    t.string "first_name"
    t.string "last_name"
    t.string "locale"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.string "web3_address"
    t.string "webauthn_id"
    t.text "webauthn_public_key"
    t.integer "webauthn_sign_count", default: 0, null: false
    t.index ["email"], name: "index_lato_users_on_email", unique: true
  end

  create_table "product_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_items_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.integer "lato_user_id"
    t.integer "product_parent_id"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["lato_user_id"], name: "index_products_on_lato_user_id"
    t.index ["product_parent_id"], name: "index_products_on_product_parent_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "lato_invitations", "lato_users"
  add_foreign_key "lato_invitations", "lato_users", column: "inviter_lato_user_id"
  add_foreign_key "lato_log_user_signins", "lato_users"
  add_foreign_key "lato_log_user_signups", "lato_users"
  add_foreign_key "lato_operations", "lato_users"
  add_foreign_key "product_items", "products"
  add_foreign_key "products", "lato_users"
  add_foreign_key "products", "products", column: "product_parent_id"
end
