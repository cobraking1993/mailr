class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages ,:id => false do |t|
      t.integer :folder_id
      t.integer :user_id
      t.string :msg_id
      t.string :from
      t.string :to
      t.string :subject
      t.string :content_type
      t.integer :uid
      t.integer :size
      t.boolean :unread
      t.datetime :date

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
