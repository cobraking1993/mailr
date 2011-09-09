class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :user_id
      t.integer :priority
      t.text :description
      t.string :category
      t.datetime :start
      t.datetime :stop
      t.boolean :allday

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
