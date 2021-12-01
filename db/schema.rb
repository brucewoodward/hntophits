
ActiveRecord::Schema.define(version: 20200524024101) do

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

end
