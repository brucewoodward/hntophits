
# The code in this module is used by the collection services (load_db and hn_collect)
# to update the database via active record. It is the interface between rails and
# external story collection code.

module HackerNews

  def self.main(hn_id: hn_id, href: href, description: description,
                almost_stories: almost_stories, date: time)
    story = Struct.new(:hn_id, :description, :href)
    # order here is critical, process_story still will create the story if needed.
    # process_latest_hn_num_one expects the story to exist.
    story_from_db = HackerNews.process_story(story.new(hn_id: hn_id,
                                             description: description,
                                             href: href), date: date)
    HackerNews.process_latest_hn_num_one(story: story_from_db, date: date)
    HackerNews.process_almost_stories(stories: almost_stories,
                                      dbstory: story_from_db)
  end
  
  def self.process_story(story:, date:)
    Rails.logger.info "process_story: story #{story}"
    story = Story.transaction do
      Story.process(hn_id: story.hn_id, date: date, href: story.href,
                    description: story.description)
    end
  end

  def self.process_latest_hn_num_one(story:, date:)
    Story.transaction do
      TopHit.process_latest_top_story(story_id: story.id, date: date)
    end
  end

  def self.process_almost_stories(stories:, dbstory:)
    Story.process_almost_stories(stories, dbstory)
  end

  def self.build_hacker_news_href hn_id
    "https://news.ycombinator.com/item?id=#{hn_id}"
  end

  def self.time_difference_between_now_and_date_last_num_one_in_minutes date
    (Time.now - date.to_time) / 60
    #(Time.now - date) / 60
  end

end
