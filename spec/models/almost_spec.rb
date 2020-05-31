require 'rails_helper'

RSpec.describe AlmostStory, type: :model do
  # context "almost story doesn't exist, story should be created" do
  #   it "should return the story" do
  #     AlmostStory.process(hn_id: 10, href: "dummy href", description: "description")
  #     expect(AlmostStory.first.hn_id).to eq 10
  #     expect(AlmostStory.first.description).to eq "description"
  #     expect(AlmostStory.first.href).to eq "dummy href"
  #   end
  # end

  # context "the story has been created but the description has been changed by hacker news" do
  #   it "should return the original story" do
  #     AlmostStory.process(hn_id: 10, href: "dummy href", description: "description")
  #     expect(AlmostStory.first.hn_id).to eq 10
  #     expect(AlmostStory.first.description).to eq "description"
  #     expect(AlmostStory.first.href).to eq "dummy href"
  #   end
  #   it "should return the updated story" do
  #     AlmostStory.process(hn_id: 10, href: "dummy href", description: "new description")
  #     expect(AlmostStory.first.hn_id).to eq 10
  #     expect(AlmostStory.first.description).to eq "new description"
  #     expect(AlmostStory.first.href).to eq "dummy href"
  #   end
  # end

  # context "the story already exists in the stories table, meaning it's already been to #1" do
  #   s = Story.process(hn_id: 1, href: "href here", description: "my description")
  #   count = Story.count()
  #   it "created an entry in the stories table" do
  #     expect(count).to eq 1
  #   end
  #   almost_stories = [ s ]
  #   AlmostStory.process_almost_stories(almost_stories)
  #   almoststory_count = AlmostStory.count()
  #   story_count = Story.count()
  #   it "will be an empty table" do
  #     expect(almoststory_count).to eq 0
  #     expect(story_count).to eq 1
  #   end
  # end
end

RSpec.describe AlmostStory, type: :model do

  context "the story that eventually makes it" do
    ourstory = OpenStruct.new(hn_id: 333, href: "little story that could", 
                             description: "what a wonderful life")
    AlmostStory.process_almost_stories([ourstory])
    nAlmostStory = AlmostStory.count
    hn_id = AlmostStory.first.hn_id
    it "will have put the story in the almost stories table" do
      expect(hn_id).to eq 333
      expect(nAlmostStory).to eq 1
    end
    #AlmostStory.process_almost_stories([ourstory])
    #it "will still have the story in almost stories table" do
    #  expect(AlmostStory.first.hn_id).to eq 333
    #  expect(AlmostStory.count).to eq 1
    #end
  end

  #context "now the story reaches number one" do
  #  ourstory = OpenStruct.new(hn_id: 1, href: "little story that could", 
  #                           description: "what a wonderful life")
  #  Story.process(ourstory.to_h)
  #  AlmostStory.process_almost_stories([ourstory])
  #  it "be removed from the AlmostStories table and added to the Stories table" do
  #    expect(AlmostStory.where(hn_id: ourstory.hn_id).first).to be nil
  #    expect(AlmostStory.where(hn_id: ourstory.hn_id).first).not_to nil
  #  end
  #end
end
