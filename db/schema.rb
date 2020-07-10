# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_10_153438) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "cells", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "sector_id", null: false
    t.integer "gis_code"
    t.float "latitude"
    t.float "longitude"
    t.integer "population"
    t.integer "households"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "hierarchy"
    t.boolean "hidden", default: false, null: false
    t.index ["gis_code"], name: "index_cells_on_gis_code", unique: true
    t.index ["hidden"], name: "index_cells_on_hidden"
    t.index ["sector_id"], name: "index_cells_on_sector_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.money "budget", scale: 2
    t.integer "household_goal"
    t.integer "people_goal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_date", "start_date"], name: "between_end_start_dates"
    t.index ["end_date"], name: "index_contracts_on_end_date"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.integer "gis_code"
    t.float "latitude"
    t.float "longitude"
    t.integer "population"
    t.integer "households"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "hidden", default: false, null: false
    t.index ["gis_code"], name: "index_countries_on_gis_code"
    t.index ["hidden"], name: "index_countries_on_hidden"
  end

  create_table "districts", force: :cascade do |t|
    t.string "name", null: false
    t.integer "gis_code"
    t.float "latitude"
    t.float "longitude"
    t.integer "population"
    t.integer "households"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "country_id"
    t.jsonb "hierarchy"
    t.boolean "hidden", default: false, null: false
    t.index ["country_id"], name: "index_districts_on_country_id"
    t.index ["gis_code"], name: "index_districts_on_gis_code", unique: true
    t.index ["hidden"], name: "index_districts_on_hidden"
  end

  create_table "facilities", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.float "latitude"
    t.float "longitude"
    t.integer "population"
    t.integer "households"
    t.string "category", null: false
    t.bigint "village_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "hierarchy"
    t.index ["village_id"], name: "index_facilities_on_village_id"
  end

  create_table "plans", force: :cascade do |t|
    t.bigint "contract_id", null: false
    t.bigint "technology_id", null: false
    t.integer "goal", null: false
    t.integer "people_goal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "planable_id"
    t.string "planable_type"
    t.date "date"
    t.jsonb "hierarchy"
    t.index ["contract_id", "technology_id", "planable_id", "planable_type"], name: "idx_has_many_reports", unique: true
    t.index ["contract_id"], name: "index_plans_on_contract_id"
    t.index ["created_at"], name: "index_plans_on_created_at"
    t.index ["date"], name: "index_plans_on_date"
    t.index ["planable_type", "planable_id"], name: "index_plans_on_planable_type_and_planable_id"
    t.index ["technology_id"], name: "index_plans_on_technology_id"
  end

  create_table "reports", force: :cascade do |t|
    t.date "date"
    t.bigint "technology_id", null: false
    t.bigint "user_id", null: false
    t.bigint "contract_id"
    t.integer "distributed"
    t.integer "checked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "people"
    t.integer "reportable_id"
    t.string "reportable_type"
    t.integer "impact", default: 0
    t.bigint "plan_id"
    t.integer "year"
    t.integer "month"
    t.decimal "hours", precision: 5, scale: 2, default: "0.0"
    t.jsonb "hierarchy"
    t.index ["contract_id", "technology_id", "reportable_id", "reportable_type"], name: "idx_belongs_to_plan"
    t.index ["contract_id"], name: "index_reports_on_contract_id"
    t.index ["date"], name: "index_reports_on_date"
    t.index ["plan_id"], name: "index_reports_on_plan_id"
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable_type_and_reportable_id"
    t.index ["technology_id"], name: "index_reports_on_technology_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "sectors", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "district_id", null: false
    t.integer "gis_code"
    t.float "latitude"
    t.float "longitude"
    t.integer "population"
    t.integer "households"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "hierarchy"
    t.boolean "hidden", default: false, null: false
    t.index ["district_id"], name: "index_sectors_on_district_id"
    t.index ["gis_code"], name: "index_sectors_on_gis_code", unique: true
    t.index ["hidden"], name: "index_sectors_on_hidden"
  end

  create_table "stories", force: :cascade do |t|
    t.string "title"
    t.text "text"
    t.bigint "report_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "prominent", default: false
    t.bigint "user_id", null: false
    t.index ["report_id"], name: "index_stories_on_report_id"
    t.index ["user_id"], name: "index_stories_on_user_id"
  end

  create_table "targets", force: :cascade do |t|
    t.bigint "contract_id", null: false
    t.bigint "technology_id", null: false
    t.integer "goal", null: false
    t.integer "people_goal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_targets_on_contract_id"
    t.index ["technology_id"], name: "index_targets_on_technology_id"
  end

  create_table "technologies", force: :cascade do |t|
    t.string "name", null: false
    t.string "short_name", null: false
    t.integer "default_impact", null: false
    t.boolean "report_worthy", default: true, null: false
    t.boolean "agreement_required", default: false, null: false
    t.string "scale", null: false
    t.integer "direct_cost_cents", default: 0, null: false
    t.string "direct_cost_currency", default: "USD", null: false
    t.integer "indirect_cost_cents", default: 0, null: false
    t.string "indirect_cost_currency", default: "USD", null: false
    t.integer "us_cost_cents", default: 0, null: false
    t.string "us_cost_currency", default: "USD", null: false
    t.integer "local_cost_cents", default: 0, null: false
    t.string "local_cost_currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_name"
    t.text "description"
    t.boolean "is_engagement", default: false
    t.boolean "dashboard_worthy", default: true
    t.index ["dashboard_worthy"], name: "index_technologies_on_dashboard_worthy"
    t.index ["is_engagement"], name: "index_technologies_on_is_engagement"
    t.index ["report_worthy"], name: "index_technologies_on_report_worthy"
  end

  create_table "users", force: :cascade do |t|
    t.string "fname", null: false
    t.string "lname", null: false
    t.boolean "admin", default: false, null: false
    t.boolean "can_manage_reports", default: false, null: false
    t.boolean "can_manage_geography", default: false, null: false
    t.boolean "can_manage_contracts", default: false, null: false
    t.boolean "can_manage_technologies", default: false, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "villages", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "cell_id", null: false
    t.integer "gis_code"
    t.float "latitude"
    t.float "longitude"
    t.integer "population"
    t.integer "households"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "hierarchy"
    t.boolean "hidden", default: false, null: false
    t.index ["cell_id"], name: "index_villages_on_cell_id"
    t.index ["gis_code"], name: "index_villages_on_gis_code", unique: true
    t.index ["hidden"], name: "index_villages_on_hidden"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "plans", "contracts"
  add_foreign_key "plans", "technologies"
  add_foreign_key "reports", "contracts"
  add_foreign_key "reports", "plans"
  add_foreign_key "reports", "technologies"
  add_foreign_key "reports", "users"
  add_foreign_key "stories", "reports"
  add_foreign_key "stories", "users"
  add_foreign_key "targets", "contracts"
  add_foreign_key "targets", "technologies"
end
