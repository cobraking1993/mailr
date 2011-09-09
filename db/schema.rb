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

ActiveRecord::Schema.define(:version => 20110908094506) do

  create_table "contacts", :force => true do |t|
    t.string   "nick"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "info"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.integer  "priority"
    t.text     "description"
    t.string   "category"
    t.datetime "start"
    t.datetime "stop"
    t.boolean  "allday"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "folders", :force => true do |t|
    t.string   "name"
    t.string   "delim"
    t.boolean  "haschildren"
    t.integer  "total"
    t.integer  "unseen"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parent"
    t.boolean  "shown"
    t.string   "alter_name"
    t.integer  "sys"
  end

  create_table "messages", :id => false, :force => true do |t|
    t.integer  "folder_id"
    t.integer  "user_id"
    t.string   "msg_id"
    t.string   "from_addr"
    t.string   "to_addr"
    t.string   "subject"
    t.string   "content_type"
    t.integer  "uid"
    t.integer  "size"
    t.boolean  "unseen"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prefs", :force => true do |t|
    t.string   "theme"
    t.string   "locale"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "msgs_per_page"
    t.string   "msg_send_type"
    t.string   "msg_image_view_as"
    t.string   "msg_image_thumbnail_size"
  end

  create_table "servers", :force => true do |t|
    t.string   "name"
    t.string   "port"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "use_ssl"
    t.boolean  "use_tls"
    t.boolean  "for_imap"
    t.boolean  "for_smtp"
    t.string   "auth"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "domain"
  end

end
