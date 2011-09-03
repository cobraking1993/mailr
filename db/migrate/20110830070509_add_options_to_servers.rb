class AddOptionsToServers < ActiveRecord::Migration
  def self.up
    add_column :servers,:use_tls,:boolean
    add_column :servers,:for_imap,:boolean
    add_column :servers,:for_smtp,:boolean
  end

  def self.down
    remove_column :servers,:use_tls
    remove_column :servers,:for_imap
    remove_column :servers,:for_smtp
  end
end
