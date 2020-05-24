class AlmostStory < ApplicationRecord

  scope :by_time_created, -> { order(created_at: :desc) }

  # create the story if needed.
  # update the description if hackernews has changed it (admins happen)
  # save away the possibly updated story.
  def self.process(hn_id:, href:, description:)
    story = AlmostStory.find_or_create_by!(hn_id: hn_id) do |r|
      r.href = href.blank? ? HackerNews.build_hacker_news_href(hn_id) : href
      r.description = description
    end
    story.description = description if story.description != description
    story.save
    story
  end

  def self.process_almost_stories(stories)
    stories.each do |story|
      s = Story.where(hn_id: story.hn_id).first
      if s and AlmostStory.where(hn_id: story.hn_id).count > 0
        AlmostStory.where(hn_id: story.hn_id).destroy_all
      elsif AlmostStory.where(hn_id: story.hn_id).empty? # new entry in almost story
        AlmostStory.process(hn_id: story.hn_id,
                            href: story.href,
                            description: story.description)
      end
    end
  end

end
