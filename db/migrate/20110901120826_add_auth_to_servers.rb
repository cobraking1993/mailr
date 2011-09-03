class AddAuthToServers < ActiveRecord::Migration
  def self.up
    add_column :servers, :auth, :string
  end

  def self.down
    remove_column :servers, :auth
  end
end
