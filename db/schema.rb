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

ActiveRecord::Schema[7.2].define(version: 2025_12_01_151350) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "membership_requests", force: :cascade do |t|
    t.bigint "requester_profile_id", null: false
    t.bigint "target_profile_id"
    t.bigint "team_id"
    t.integer "direction", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.index ["requester_profile_id", "target_profile_id", "team_id", "direction"], name: "idx_membership_requests_uniqueness"
    t.index ["requester_profile_id"], name: "index_membership_requests_on_requester_profile_id"
    t.index ["target_profile_id"], name: "index_membership_requests_on_target_profile_id"
    t.index ["team_id"], name: "index_membership_requests_on_team_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "label"
    t.string "theme"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name"
    t.string "join_token"
    t.index ["join_token"], name: "index_profiles_on_join_token", unique: true
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "team_memberships", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.bigint "team_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id", "team_id"], name: "index_team_memberships_on_profile_id_and_team_id", unique: true
    t.index ["profile_id"], name: "index_team_memberships_on_profile_id"
    t.index ["team_id"], name: "index_team_memberships_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "join_token"
    t.index ["join_token"], name: "index_teams_on_join_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "membership_requests", "profiles", column: "requester_profile_id"
  add_foreign_key "membership_requests", "profiles", column: "target_profile_id"
  add_foreign_key "membership_requests", "teams"
  add_foreign_key "profiles", "users"
  add_foreign_key "team_memberships", "profiles"
  add_foreign_key "team_memberships", "teams"
end
