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

ActiveRecord::Schema[7.0].define(version: 2024_09_23_021814) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bids", force: :cascade do |t|
    t.decimal "monthly_price", precision: 10, scale: 2, null: false
    t.integer "lease_period", null: false
    t.string "status", default: "active", null: false
    t.bigint "commodity_id", null: false
    t.bigint "renter_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commodity_id", "renter_id"], name: "index_bids_on_commodity_id_and_renter_id", unique: true, where: "((status)::text = 'active'::text)"
    t.index ["commodity_id"], name: "index_bids_on_commodity_id"
    t.index ["renter_id"], name: "index_bids_on_renter_id"
  end

  create_table "commodities", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "category", null: false
    t.decimal "minimum_monthly_charge", precision: 10, scale: 2, null: false
    t.string "status", default: "available", null: false
    t.string "bid_strategy", null: false
    t.bigint "lender_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "bidding_start_time"
    t.index ["lender_id"], name: "index_commodities_on_lender_id"
    t.index ["status"], name: "index_commodities_on_status"
  end

  create_table "jwt_deny_entries", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_deny_entries_on_jti"
  end

  create_table "rentals", force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.decimal "monthly_price", precision: 10, scale: 2, null: false
    t.string "status", default: "active", null: false
    t.bigint "commodity_id", null: false
    t.bigint "renter_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commodity_id"], name: "index_rentals_on_commodity_id"
    t.index ["renter_id"], name: "index_rentals_on_renter_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "role", default: "renter", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bids", "commodities"
  add_foreign_key "bids", "users", column: "renter_id"
  add_foreign_key "commodities", "users", column: "lender_id"
  add_foreign_key "rentals", "commodities"
  add_foreign_key "rentals", "users", column: "renter_id"
end
