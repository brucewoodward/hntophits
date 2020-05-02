
# The code in this module is used by the collection services (load_db and hn_collect)
# to update the database via active record. It is the interface between rails and
# external story collection code.

module HackerNews

  def self.process_latest_hn_num_one(hn_id:, date:, href:, description:)
    Story.transaction do
      story = Story.process(hn_id: hn_id, date: date, href: href, description: description)
      TopHit.process_latest_top_story(story_id: story.id, date: date)
    end
  end

  def self.build_hacker_news_href hn_id
    "https://news.ycombinator.com/item?id=#{hn_id}"
  end

  def self.time_difference_between_now_and_date_last_num_one_in_minutes date
    (Time.now - date.to_time) / 60
    #(Time.now - date) / 60
  end

end
