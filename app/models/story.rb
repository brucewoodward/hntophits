class Story < ApplicationRecord

  has_many :top_hits, dependent: :destroy

  validates :hn_id, numericality: { only_integer: true }
  validates :time_at_num_one, numericality: { only_integer: true }
  validates :href, presence: true
  validates :description, presence: true
  validates_uniqueness_of :hn_id

  #scope :last_seen, -> (direction) { order(updated_at: direction) }
  scope :last_seen, -> { order(updated_at: :desc) }
  scope :most_time_at_number_one, -> { order(time_at_num_one: :desc) }

  scope :by_most_time, -> { order(time_at_num_one: :desc).limit(15) }
  scope :newer_than_days, ->(days) { where('updated_at > ?', days).by_most_time }
  scope :last_week, -> { newer_than_days(1.week.ago) }
  scope :last_month, -> { newer_than_days(1.month.ago) }
  scope :all_time, -> { by_most_time }

  scope :time_at_num_one, -> (direction) { order(time_at_num_one: direction) }

  def top_hit
    TopHit.top_hit(self).first
  end

  def self.process(hn_id:, href:, description:)
    Rails.logger.error "Story.process hn_id #{hn_id} href #{href} description #{description}"
    story = Story.find_or_create_by!(hn_id: hn_id) do |r|
      r.href = href.blank? ? HackerNews.build_hacker_news_href(hn_id) : href
      r.description = description
    end
    story.description = description if story.description != description
    story.time_at_num_one += 1
    story.save!
    story
  end

  def self.get_ordered_num_one_stories time_frame
    case time_frame
    when nil, 'week'
      Story.last_week
    when 'month'
      Story.last_month
    when 'alltime'
      Story.all_time
    else
      Story.last_week
    end
  end

end
