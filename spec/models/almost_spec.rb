require 'rails_helper'

RSpec.describe AlmostStory, type: :model do
  context "almost story doesn't exist, story should be created" do
    it "should return the story" do
      AlmostStory.process(hn_id: 10, href: "dummy href", description: "description")
      expect(AlmostStory.first.hn_id).to eq 10
      expect(AlmostStory.first.description).to eq "description"
      expect(AlmostStory.first.href).to eq "dummy href"
    end
  end

  context "the story has been created but the description has been changed by hacker news" do
    it "should return the original story" do
      AlmostStory.process(hn_id: 10, href: "dummy href", description: "description")
      expect(AlmostStory.first.hn_id).to eq 10
      expect(AlmostStory.first.description).to eq "description"
      expect(AlmostStory.first.href).to eq "dummy href"
    end
    it "should return the updated story" do
      AlmostStory.process(hn_id: 10, href: "dummy href", description: "new description")
      expect(AlmostStory.first.hn_id).to eq 10
      expect(AlmostStory.first.description).to eq "new description"
      expect(AlmostStory.first.href).to eq "dummy href"
    end
  end

  context "the story already exists in the stories table, meaning it's already been to #1" do
    before(:each) do
      @s = Story.process(hn_id: 1, href: "href here", description: "my description")
    end

    it "created an entry in the stories table" do
      expect(Story.count()).to eq 1
    end

    it "should be an empty table" do
      almost_stories = [ @s ]
      AlmostStory.process_almost_stories(almost_stories)
      almoststory_count = AlmostStory.count()
      story_count = Story.count()
      expect(almoststory_count).to eq 0
      expect(story_count).to eq 1
    end
  end
end

RSpec.describe AlmostStory, type: :model do

  context "the story that eventually makes it" do
    before(:each) do
      @ourstory = OpenStruct.new(hn_id: 333, href: "little story that could", 
                             description: "what a wonderful life")
    end

    # simulating consecutive calls to top hits site.
    # first time, the story is put in the almost stories table.
    it "will have put the story in the almost stories table" do
      AlmostStory.process_almost_stories([@ourstory])
      expect(AlmostStory.first.hn_id).to eq 333
      expect(AlmostStory.count).to eq 1
    end

    # second time, it's still there in the table.
    it "will still have the story in almost stories table" do
      AlmostStory.process_almost_stories([@ourstory])
      expect(AlmostStory.count).to eq 1
      expect(AlmostStory.first.hn_id).to eq 333
    end

    # now the story has made it number #1
    it "be removed from the AlmostStories table and added to the Stories table" do
      Story.process(@ourstory.to_h)
      AlmostStory.process_almost_stories([@ourstory])
      AlmostStory.remove_top_story(@ourstory)
      # story has been removed from the almost_stories table
      expect(AlmostStory.where(hn_id: @ourstory.hn_id).first).to be_falsey
    end
  end
end
