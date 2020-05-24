class DefaultTimeAtNumOneIsZero < ActiveRecord::Migration[5.1]
  def change
    change_column :stories, :time_at_num_one, :integer, :default => 0
  end
end
