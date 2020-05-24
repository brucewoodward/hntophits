class RemoveAlmostTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :almost_tables
  end
end
