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

ActiveRecord::Schema[8.1].define(version: 2026_02_27_032708) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "customers", force: :cascade do |t|
    t.bigint "added_by_id", null: false
    t.text "address"
    t.string "co_maker"
    t.string "collateral"
    t.string "contact_number"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "first_name"
    t.string "id_submitted"
    t.string "last_name"
    t.string "middle_initial"
    t.integer "total_no_of_loans"
    t.datetime "updated_at", null: false
    t.index ["added_by_id"], name: "index_customers_on_added_by_id"
  end

  create_table "loans", force: :cascade do |t|
    t.bigint "added_by_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.datetime "date_added", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.date "date_issued"
    t.decimal "interest_rate", precision: 5, scale: 4, null: false
    t.bigint "issued_by_id"
    t.decimal "loan_amount", precision: 12, scale: 2, null: false
    t.date "maturity_date"
    t.decimal "pay_per_session", precision: 12, scale: 2
    t.decimal "remaining_balance", precision: 12, scale: 2
    t.string "session_type", default: "weekly", null: false
    t.string "status", default: "active", null: false
    t.decimal "total_balance", precision: 12, scale: 2
    t.integer "total_months_to_pay", default: 2, null: false
    t.integer "total_sessions"
    t.datetime "updated_at", null: false
    t.index ["added_by_id"], name: "index_loans_on_added_by_id"
    t.index ["customer_id"], name: "index_loans_on_customer_id"
    t.index ["issued_by_id"], name: "index_loans_on_issued_by_id"
    t.index ["maturity_date"], name: "index_loans_on_maturity_date"
    t.index ["status"], name: "index_loans_on_status"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount_paid"
    t.string "collector"
    t.datetime "created_at", null: false
    t.bigint "loan_id", null: false
    t.datetime "paid_at"
    t.decimal "penalty"
    t.datetime "received_at"
    t.datetime "updated_at", null: false
    t.index ["loan_id"], name: "index_payments_on_loan_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "middle_initial"
    t.string "password_digest"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "customers", "users", column: "added_by_id"
  add_foreign_key "loans", "customers"
  add_foreign_key "loans", "users", column: "added_by_id"
  add_foreign_key "loans", "users", column: "issued_by_id"
  add_foreign_key "payments", "loans"
end
