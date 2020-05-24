class AddAlmostStoriesContents < ActiveRecord::Migration[5.1]
  def change
    add_column :almost_stories, :href, :string 
    add_column :almost_stories, :description, :string 
  end
end
