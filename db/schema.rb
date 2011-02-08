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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110208000933) do

  create_table "accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "editor_tokens", :force => true do |t|
    t.integer  "editor_id"
    t.string   "key"
    t.datetime "expires_at"
    t.integer  "use_count",  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "editor_tokens", ["key"], :name => "index_editor_tokens_on_key", :unique => true

  create_table "editors", :force => true do |t|
    t.string   "email"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.boolean  "is_owner",   :default => false
  end

  add_index "editors", ["account_id", "email"], :name => "index_editors_on_account_id_and_email", :unique => true

  create_table "edits", :force => true do |t|
    t.string   "url"
    t.string   "element_path"
    t.text     "original"
    t.text     "proposed"
    t.string   "status",       :default => "new"
    t.string   "ip_address"
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "user_name"
    t.boolean  "opt_in",       :default => false
    t.integer  "distance"
    t.string   "key"
    t.text     "comments"
  end

  add_index "edits", ["page_id"], :name => "index_edits_on_page_id"

  create_table "emails", :force => true do |t|
    t.binary "raw"
    t.string "digest"
    t.string "type"
  end

  add_index "emails", ["digest"], :name => "index_emails_on_digest", :unique => true

  create_table "pages", :force => true do |t|
    t.string   "key"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "pages", ["account_id", "key"], :name => "index_pages_on_account_id_and_key", :unique => true
  add_index "pages", ["key"], :name => "index_pages_on_host_and_key", :unique => true

  create_table "sites", :force => true do |t|
    t.integer  "account_id"
    t.string   "host"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
