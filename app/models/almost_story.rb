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
    Rails.logger.error "inside almoststory.process #{story.inspect}"
    story.description = description if story.description != description
    story.save
    story
  end

  def self.process_almost_stories(stories)
    stories.each do |story|

      seen_story_before = Story.where(hn_id: story.hn_id).first
      story_is_in_almoststory = AlmostStory.where(hn_id: story.hn_id).count > 0

      Rails.logger.error "seen_story_before #{seen_story_before.inspect}"
      if seen_story_before
        if story_is_in_almoststory
          # remove it, because the story has been #1 at some point
          AlmostStory.where(hn_id: story.hn_id).destroy_all
        end
      else
        Rails.logger.error "running almoststory.process"
        AlmostStory.process(hn_id: story.hn_id, # add story
                                href: story.href,
                                description: story.description)
      end
    end
  end

  def self.remove_top_story(top_story)
    # remote current number one story from the almost_stories table.
    AlmostStory.where(hn_id: top_story.hn_id).destroy_all
  end

end
