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

ActiveRecord::Schema[7.2].define(version: 2025_12_25_155618) do
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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "chat_members", force: :cascade do |t|
    t.bigint "chat_room_id", null: false
    t.bigint "profile_id", null: false
    t.string "room_display_name"
    t.integer "unread_count", default: 0, null: false
    t.datetime "last_read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_chat_members_on_chat_room_id"
    t.index ["profile_id"], name: "index_chat_members_on_profile_id"
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "creator_profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_profile_id"], name: "index_chat_rooms_on_creator_profile_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "author_profile_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pinned", default: false, null: false
    t.index ["author_profile_id"], name: "index_comments_on_author_profile_id"
    t.index ["task_id"], name: "index_comments_on_task_id"
  end

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
    t.integer "target_team_id"
    t.index ["requester_profile_id", "target_profile_id", "team_id", "direction"], name: "idx_membership_requests_uniqueness"
    t.index ["requester_profile_id"], name: "index_membership_requests_on_requester_profile_id"
    t.index ["target_profile_id"], name: "index_membership_requests_on_target_profile_id"
    t.index ["target_team_id"], name: "index_membership_requests_on_target_team_id"
    t.index ["team_id"], name: "index_membership_requests_on_team_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chat_room_id", null: false
    t.bigint "author_profile_id", null: false
    t.text "body"
    t.boolean "pinned", default: false
    t.datetime "edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_message_id"
    t.index ["author_profile_id"], name: "index_messages_on_author_profile_id"
    t.index ["chat_room_id"], name: "index_messages_on_chat_room_id"
    t.index ["parent_message_id"], name: "index_messages_on_parent_message_id"
  end

  create_table "post_comments", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "author_profile_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_profile_id"], name: "index_post_comments_on_author_profile_id"
    t.index ["post_id"], name: "index_post_comments_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.integer "post_type"
    t.text "body"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_posts_on_profile_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "label"
    t.string "theme"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name"
    t.string "join_token"
    t.string "locale"
    t.integer "primary_team_id"
    t.index ["join_token"], name: "index_profiles_on_join_token", unique: true
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reactable_type"
    t.bigint "reactable_id"
    t.index ["profile_id"], name: "index_reactions_on_profile_id"
    t.index ["reactable_type", "reactable_id"], name: "index_reactions_on_reactable"
  end

  create_table "reposts", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.bigint "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_reposts_on_post_id"
    t.index ["profile_id"], name: "index_reposts_on_profile_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "task_assignments", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_task_assignments_on_profile_id"
    t.index ["task_id", "profile_id"], name: "index_task_assignments_on_task_id_and_profile_id", unique: true
    t.index ["task_id"], name: "index_task_assignments_on_task_id"
  end

  create_table "task_tags", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_task_tags_on_tag_id"
    t.index ["task_id", "tag_id"], name: "index_task_tags_on_task_id_and_tag_id", unique: true
    t.index ["task_id"], name: "index_task_tags_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "owner_profile_id", null: false
    t.bigint "assignee_profile_id"
    t.bigint "team_id"
    t.string "title", null: false
    t.text "description"
    t.datetime "due_at"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_profile_id"], name: "index_tasks_on_assignee_profile_id"
    t.index ["owner_profile_id"], name: "index_tasks_on_owner_profile_id"
    t.index ["team_id"], name: "index_tasks_on_team_id"
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
    t.integer "parent_id"
    t.index ["join_token"], name: "index_teams_on_join_token", unique: true
    t.index ["parent_id"], name: "index_teams_on_parent_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "works", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.bigint "team_id"
    t.string "title"
    t.text "body"
    t.string "work_type"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_works_on_profile_id"
    t.index ["team_id"], name: "index_works_on_team_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chat_members", "chat_rooms"
  add_foreign_key "chat_members", "profiles"
  add_foreign_key "chat_rooms", "profiles", column: "creator_profile_id"
  add_foreign_key "comments", "profiles", column: "author_profile_id"
  add_foreign_key "comments", "tasks"
  add_foreign_key "membership_requests", "profiles", column: "requester_profile_id"
  add_foreign_key "membership_requests", "profiles", column: "target_profile_id"
  add_foreign_key "membership_requests", "teams"
  add_foreign_key "messages", "chat_rooms"
  add_foreign_key "messages", "profiles", column: "author_profile_id"
  add_foreign_key "post_comments", "posts"
  add_foreign_key "post_comments", "profiles", column: "author_profile_id"
  add_foreign_key "posts", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "reactions", "profiles"
  add_foreign_key "reposts", "posts"
  add_foreign_key "reposts", "profiles"
  add_foreign_key "task_assignments", "profiles"
  add_foreign_key "task_assignments", "tasks"
  add_foreign_key "task_tags", "tags"
  add_foreign_key "task_tags", "tasks"
  add_foreign_key "tasks", "profiles", column: "assignee_profile_id"
  add_foreign_key "tasks", "profiles", column: "owner_profile_id"
  add_foreign_key "tasks", "teams"
  add_foreign_key "team_memberships", "profiles"
  add_foreign_key "team_memberships", "teams"
  add_foreign_key "teams", "teams", column: "parent_id"
  add_foreign_key "works", "profiles"
  add_foreign_key "works", "teams"
end
