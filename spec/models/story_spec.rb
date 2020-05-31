require 'rails_helper'

RSpec.describe Story, type: :model do
  context "get_ordered_num_one_stories for week" do
    context "when data is found to be returned" do
      before(:each) do
        Story.create(hn_id: 1, href: "fred", description: "first record").update(updated_at: 2.week.ago)
        Story.create(hn_id: 2, href: "bert", description: "second record").update(updated_at: 3.days.ago)
      end
      it "should return the 3 day old record when given nil" do
        expect(Story.get_ordered_num_one_stories(nil).first.hn_id).to eq 2
      end
      it "should return the 3 day old record when given the string 'week'" do
        expect(Story.get_ordered_num_one_stories('week').first.hn_id).to eq 2
      end
      it "should return the 3 day old record when given invalid input" do
        expect(Story.get_ordered_num_one_stories(:wrong).first.hn_id).to eq 2
      end
    end
    context "when no data is found to be returned" do
      before(:each) do
        Story.create(hn_id: 1, href: "fred", description: "first record").update(updated_at: 2.week.ago)
      end
      it "should return the empty array when give nil" do
        expect(Story.get_ordered_num_one_stories(nil).length).to eq 0
      end
      it "should return the empty array when given then string 'week'" do
        expect(Story.get_ordered_num_one_stories(nil).length).to eq 0
      end
      it "should return the empty array when given invalid input" do
        expect(Story.get_ordered_num_one_stories(nil).length).to eq 0
      end
    end
  end

  context "get_ordered_num_one_stories for month" do
    context "when data is found to be returned" do
      before(:each) do
        Story.create(hn_id: 1, href: "fred", description: "first record").update(updated_at: 2.month.ago)
        Story.create(hn_id: 2, href: "bert", description: "second record").update(updated_at: 3.week.ago)
      end
      it "should return the 3 week old record when given the string 'week'" do
        expect(Story.get_ordered_num_one_stories('month').first.hn_id).to eq 2
      end
    end
    context "when no data is found to be returned" do
      before(:each) do
        Story.create(hn_id: 1, href: "fred", description: "first record").update(updated_at: 2.week.ago)
      end
      it "should return the empty array when given then string 'month'" do
        expect(Story.get_ordered_num_one_stories(nil).length).to eq 0
      end
    end
  end

  context "get_ordered_num_one_stories for all time" do
    context "when data is found to be returned" do
      before(:each) do
        Story.create(hn_id: 1, href: "fred", description: "first record").update(updated_at: 2.month.ago)
        Story.create(hn_id: 2, href: "bert", description: "second record").update(updated_at: 3.week.ago)
        Story.create(hn_id: 3, href: "erny", description: "third record").update(updated_at: 9.month.ago)
      end
      it "should return all of the records" do
        expect(Story.get_ordered_num_one_stories('alltime').length).to eq 3
      end
    end
  end

  context "exercise self.process" do

    context "successful use" do
      it "will return story that has been populated as expected (correctly)" do
        description = "description"
        href = "href"
        story = Story.process(hn_id: 1, description: description, href: href)
        expect(story.hn_id).to eq 1
        expect(story.description).to eq description
        expect(story.href).to eq href
      end
    end

    context "the story exists but the description has changed" do
      it "will update the story with the new description" do
        story = create(:story, hn_id: 1, description: "original description")
        Story.process(hn_id: 1, href: "https//nowhere.com", description: "new description")
        expect(Story.first.description).to eq "new description"
      end
    end

    context "the story doesn't exist before processsing and it's description is stored as provided" do
      it "will find that the description is as provided" do
        story = create(:story, hn_id: 1, description: "original description")
        Story.process(hn_id: 1, href: "https//nowhere.com", description: "original description")
        expect(Story.first.description).to eq "original description"
      end
    end

    context "when there are errors" do
      context "hacker news id is invalid" do
        it "should throw ActiveRecord::RecordInvalid" do
          expect {
            Story.process(hn_id: "a string", description: "description", href: nil)
          }.to raise_error(ActiveRecord::RecordInvalid)
          expect(Story.count).to eq 0
        end
      end

      context "href is nil or empty string" do
        it "will create href with the default" do
          hn_id = 1
          story = Story.process(hn_id: hn_id, description: "description", href: nil)
          expect(story.valid?).to be true
          expect(story.href).to eq HackerNews.build_hacker_news_href(hn_id)
          expect(story.description).to eq "description"
        end

        it "will create href with the default" do
          hn_id = 1
          story = Story.process(hn_id: hn_id, description: "description", href: '')
          expect(story.valid?).to be true
          expect(story.href).to eq HackerNews.build_hacker_news_href(hn_id)
          expect(story.description).to eq "description"
        end
      end

      context "description is nil is invalid" do
        it "should throw ActiveRecord::RecordInvalid" do
          expect {
            Story.process(hn_id: "a string", description: nil, href: nil)
          }.to raise_error(ActiveRecord::RecordInvalid)
          expect(Story.count).to eq 0
        end
      end
    end
  end

end
