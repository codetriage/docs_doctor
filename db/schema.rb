# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20130720231123) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "doc_classes", force: true do |t|
    t.integer  "doc_file_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "doc_comments_count", default: 0, null: false
  end

  add_index "doc_classes", ["doc_file_id"], name: "index_doc_classes_on_doc_file_id", using: :btree

  create_table "doc_comments", force: true do |t|
    t.integer  "doc_class_id"
    t.integer  "doc_method_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "doc_comments", ["doc_class_id"], name: "index_doc_comments_on_doc_class_id", using: :btree
  add_index "doc_comments", ["doc_method_id"], name: "index_doc_comments_on_doc_method_id", using: :btree

  create_table "doc_files", force: true do |t|
    t.integer  "repo_id"
    t.string   "name"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "doc_files", ["repo_id"], name: "index_doc_files_on_repo_id", using: :btree

  create_table "doc_methods", force: true do |t|
    t.integer  "doc_class_id"
    t.string   "name"
    t.integer  "line"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "doc_comments_count", default: 0, null: false
  end

  add_index "doc_methods", ["doc_class_id"], name: "index_doc_methods_on_doc_class_id", using: :btree

  create_table "repo_subscriptions", force: true do |t|
    t.datetime "last_sent_at"
    t.integer  "email_limit",  default: 1
    t.integer  "user_id"
    t.integer  "repo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repo_subscriptions", ["repo_id"], name: "index_repo_subscriptions_on_repo_id", using: :btree
  add_index "repo_subscriptions", ["user_id"], name: "index_repo_subscriptions_on_user_id", using: :btree

  create_table "repos", force: true do |t|
    t.string   "name"
    t.string   "user_name"
    t.integer  "issues_count", default: 0, null: false
    t.string   "language"
    t.string   "description"
    t.string   "full_name"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                              default: "", null: false
    t.string   "encrypted_password",     limit: 128, default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
