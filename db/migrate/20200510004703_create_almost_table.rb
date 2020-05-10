class CreateAlmostTable < ActiveRecord::Migration[5.1]
  def change
    create_table :almost_tables do |t|
      t.integer :hn_id
      t.timestamps
    end
    add_index :almost_tables, :hn_id
  end
end
