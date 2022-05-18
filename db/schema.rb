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

ActiveRecord::Schema.define(version: 2020_05_24_024101) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "almost_stories", force: :cascade do |t|
    t.integer "hn_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "href"
    t.string "description"
    t.index ["hn_id"], name: "index_almost_stories_on_hn_id"
  end

  create_table "stories", id: :serial, force: :cascade do |t|
    t.integer "hn_id"
    t.text "href"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "time_at_num_one", default: 0
    t.index ["hn_id"], name: "index_stories_on_hn_id"
  end

  create_table "top_hits", id: :serial, force: :cascade do |t|
    t.integer "story_id"
    t.datetime "date_seen"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["story_id"], name: "index_top_hits_on_story_id"
  end

end

# Below is the table that is the destination.
# almost_stories and top_hits can be removed if the following table is implemented.
# 
# The highest_position column defines whether the story is a top or and almost_hit.
# If the highest_position is 1 then it's a top_hit otherwise it's an almost_hit.
# So simple.
# 
# create_table "new_stories", id: :serial, force: :cascade do |t|
#   t.integer "hn_id"
#   t.text "href"
#   t.text "description"
#   t.datetime "created_at"
#   t.datetime "updated_at"
#   t.integer "highest_position", default: None
#   t.integer "time_at_num_one", default: 0
#   t.index ["hn_id"], name: "index_stories_on_hn_id"
# end

