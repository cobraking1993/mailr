class AddTypeToFolders < ActiveRecord::Migration
  def self.up
    add_column :folders, :sys, :integer
  end

  def self.down
    remove_column :folders, :sys
  end
end
