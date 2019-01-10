# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_01_10_210841) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cells", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "sector_id", null: false
    t.integer "gis_id"
    t.float "latitude"
    t.float "longitude"
    t.integer "population"
    t.integer "households"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gis_id"], name: "index_cells_on_gis_id", unique: true
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
  end

  create_table "districts", force: :cascade do |t|
    t.string "name", null: false
    t.integer "gis_id"
    t.float "latitude"
    t.float "longitude"
    t.integer "population"
    t.integer "households"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gis_id"], name: "index_districts_on_gis_id", unique: true
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
    t.index ["village_id"], name: "index_facilities_on_village_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "model_class", null: false
    t.boolean "can_create", default: false, null: false
    t.boolean "can_read", default: false, null: false
    t.boolean "can_update", default: false, null: false
    t.boolean "can_delete", default: false, null: false
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.bigint "contract_id", null: false
    t.bigint "technology_id", null: false
    t.string "model_gid", null: false
    t.integer "goal", null: false
    t.integer "people_goal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_plans_on_contract_id"
    t.index ["technology_id"], name: "index_plans_on_technology_id"
  end

  create_table "sectors", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "district_id", null: false
    t.integer "gis_id"
    t.float "latitude"
    t.float "longitude"
    t.integer "population"
    t.integer "households"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["district_id"], name: "index_sectors_on_district_id"
    t.index ["gis_id"], name: "index_sectors_on_gis_id", unique: true
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
  end

  create_table "updates", force: :cascade do |t|
    t.date "date"
    t.bigint "technology_id", null: false
    t.bigint "user_id", null: false
    t.string "model_gid", null: false
    t.integer "distributed"
    t.integer "checked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["technology_id"], name: "index_updates_on_technology_id"
    t.index ["user_id"], name: "index_updates_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "fname", null: false
    t.string "lname", null: false
    t.boolean "admin", default: false, null: false
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
    t.integer "gis_id"
    t.float "latitude"
    t.float "longitude"
    t.integer "population"
    t.integer "households"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cell_id"], name: "index_villages_on_cell_id"
    t.index ["gis_id"], name: "index_villages_on_gis_id", unique: true
  end

  add_foreign_key "plans", "contracts"
  add_foreign_key "plans", "technologies"
  add_foreign_key "targets", "contracts"
  add_foreign_key "targets", "technologies"
  add_foreign_key "updates", "technologies"
  add_foreign_key "updates", "users"
end
