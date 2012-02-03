class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.integer :user_id
      t.integer :lgroup_id
      t.string :name
      t.string :url
      t.string :info

      t.timestamps
    end
  end

  def self.down
    drop_table :links
  end
end
