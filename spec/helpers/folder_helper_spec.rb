require 'spec_helper'
require 'folder_helper'

describe "folder_link" do

  before :all do
    $defaults ||= YAML::load_file(Rails.root.join('config','settings.yml'))
  end

  let(:folder){Folder.new(:parent => "",
                          :name => "messages",
                          :delim => ".",
                          :haschildren => false,
                          :total => 0,
                          :unseen => 0)}

  it "trash folder has messages" do
    folder.sys = Folder::SYS_TRASH
    folder.total = 2
    helper.folder_link(:folder => folder, :active => true).should eq("<a href=\"/folders/select/messages\"><i class=\"icon-trash icon-white\"></i>#{I18n::t('folder.trash_name')}</a><form action=\"/folders/emptybin\"><button class=\"btn btn-mini btn-danger folder_action\" type=\"submit\">#{I18n::t('folder.emptybin')}</button></form>")
  end

  it "system folder unseen messages active" do
    folder.sys = Folder::SYS_INBOX
    folder.total = 2
    folder.unseen = 2
    helper.folder_link(:folder => folder, :active => true).should eq("<a href=\"/folders/select/messages\"><i class=\"icon-inbox icon-white\"></i>#{I18n::t('folder.inbox_name')}</a><span class=\"label label-important folder_info\">2</span>")
  end

  it "system folder unseen messages not active" do
    folder.sys = Folder::SYS_INBOX
    folder.total = 2
    folder.unseen = 2
    helper.folder_link(:folder => folder, :active => false).should eq("<a href=\"/folders/select/messages\"><i class=\"icon-inbox\"></i>#{I18n::t('folder.inbox_name')}</a><span class=\"label label-important folder_info\">2</span>")
  end

  it "system folder no unseen messages not active" do
    folder.sys = Folder::SYS_INBOX
    folder.unseen = 0
    folder.total = 0
    helper.folder_link(:folder => folder, :active => false).should eq("<a href=\"/folders/select/messages\"><i class=\"icon-inbox\"></i>#{I18n::t('folder.inbox_name')}</a>")
  end

end
