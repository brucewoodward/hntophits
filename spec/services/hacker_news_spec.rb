

require 'rails_helper'

RSpec.describe HackerNews do

  context "process_latest_hn_num_one: there is a new story at the top" do

    it "should have a new story as number one in top_hits" do
      current_top_story = create(:story)
      create(:top_hit, story: current_top_story, date_seen: Time.now)
      HackerNews.process_latest_hn_num_one(story: FactoryBot.create(:story, hn_id: 123456789),
																									date: Time.now + 1.minute)
      expect(TopHit.current_top_hit.story.hn_id).to eq 123456789
    end

  end

  context "process_latest_hn_num_one: there isn't new story at the top" do
    it "should have added more time to the current top story in top_hits" do
      story = Struct.new(:hn_id, :href, :description)
      current_top_story_raw = story.new(656565, "http://people.com", "description")
      current_top_story = HackerNews.process_story(story: current_top_story_raw)
      HackerNews.process_latest_hn_num_one(story: current_top_story, date: Time.now)
      expect(current_top_story.time_at_num_one).to eq 1
      expect(TopHit.current_top_hit.story.hn_id).to eq 656565
      expect(TopHit.current_top_hit.story.time_at_num_one).to eq 1
      current_top_story = HackerNews.process_story(story: current_top_story_raw)
      HackerNews.process_latest_hn_num_one(story: current_top_story, date: Time.now + 1.minute)
      expect(TopHit.current_top_hit.story.hn_id).to eq 656565
      expect(TopHit.current_top_hit.story.time_at_num_one).to eq 2
    end
  end

  context "simulate the current story getting more time at number one followed by a new story entering the picture" do
    it "should have a new story as number one in top_hits" do
      story = Struct.new(:hn_id, :href, :description)
      time = Time.now
      current_top_story_raw = story.new(656565, "http://poop.com", "garbage")

      expect(Story.count).to eq 0
      current_top_story = HackerNews.process_story(story: current_top_story_raw)
      expect(Story.count).to eq 1
      HackerNews.process_latest_hn_num_one(story: current_top_story, date: time)
      expect(TopHit.current_top_hit.story.hn_id).to eq 656565
      expect(TopHit.current_top_hit.story.time_at_num_one).to eq 1

      current_top_story = HackerNews.process_story(story: current_top_story_raw)
      HackerNews.process_latest_hn_num_one(story: current_top_story,
                                           date: time + 1.minute)
      expect(TopHit.current_top_hit.story.hn_id).to eq 656565
      expect(TopHit.current_top_hit.story.time_at_num_one).to eq 2

      new_top_story_raw = story.new(88888, "http://newtopstory.com", "blahblah")
      expect(Story.count).to eq 1
      new_top_story = HackerNews.process_story(story: new_top_story_raw)
      expect(Story.count).to eq 2
      HackerNews.process_latest_hn_num_one(story: new_top_story,
                                           date: time + 2.minutes)
      expect(TopHit.current_top_hit.story.hn_id).to eq 88888
    end
  end

  context "make the update of the database fail to exercise the transaction" do

    it "should raise an exception when the attributes to Story are invalid" do
      s = OpenStruct.new(id: nil, hn_id: "string", href: nil, description: nil)
      expect{
        HackerNews.process_latest_hn_num_one(story: s, date: Time.now)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

  end

  context "Type of date_seen in SearchStory" do
    it "should return a value without throwing an exception" do
      # for this test, the value returned isn't a concern. Rather we are concerned that 
      # an exception isn't thrown due to the object being sent being unable to respond
      # to arthimetic.
      story = create(:story, description: "python")
      create(:top_hit, story: story, date_seen: Time.now)
      expect(SearchStory.search_description("python").first.description).to eq story.description
    end
  end

end
