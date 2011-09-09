class AddMsgParamsToPrefs < ActiveRecord::Migration
  def self.up
    add_column :prefs, :msg_image_view_as, :string
    add_column :prefs, :msg_image_thumbnail_size, :string
  end

  def self.down
    remove_column :prefs, :msg_image_thumbnail_size
    remove_column :prefs, :msg_image_view_as
  end
end
