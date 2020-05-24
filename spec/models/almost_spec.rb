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

  context "process list of stories" do
    context "the story already exists in the stories table, meaning it's already been to #1" do
      AlmostStory.process(hn_id: 1, href: "href here", description: "my description")
      story = Struct.new(:hn_id, :description, :href)
      dummy_stories = [ story.new(hn_id: 1, href: "href here", description: "my description") ]
      AlmostStory.process_almost_stories(dummy_stories)
      it "will be an empty table" do
        expect(AlmostStory.count()).to eq 0
      end
    end

    context "the story doesn't exist in the stories table, so it can be added" do
      story = Struct.new(:hn_id, :description, :href)
      dummy_stories = [ story.new(hn_id: 1, href: "href here", description: "my description") ]
      AlmostStory.process_almost_stories(dummy_stories)
      it "contain the story" do
        expect(AlmostStory.count()).to eq 0
        s = AlmostStory.first()
        expect(s).to be nil
      end
    end
  end
end
