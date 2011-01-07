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

ActiveRecord::Schema.define(:version => 20110107201325) do

  create_table "editor_tokens", :force => true do |t|
    t.integer  "editor_id"
    t.string   "key"
    t.datetime "expires_at"
    t.integer  "use_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "editor_tokens", ["key"], :name => "index_editor_tokens_on_key", :unique => true

  create_table "editors", :force => true do |t|
    t.string   "email"
    t.string   "host"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "editors", ["host", "email"], :name => "index_editors_on_host_and_email", :unique => true
  add_index "editors", ["host"], :name => "index_editors_on_host"

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
  end

  add_index "edits", ["page_id"], :name => "index_edits_on_page_id"

  create_table "pages", :force => true do |t|
    t.string   "host"
    t.string   "key"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["host", "key"], :name => "index_pages_on_host_and_key", :unique => true

end
