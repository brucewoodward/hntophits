class CreateAlmostStories < ActiveRecord::Migration[5.1]
  def change
    create_table :almost_stories do |t|
      t.integer :hn_id
      t.timestamps
    end
    add_index :almost_stories, :hn_id
  end
end
