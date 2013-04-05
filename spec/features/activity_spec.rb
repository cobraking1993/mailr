# encoding: utf-8

require 'spec_helper'

describe "Setup process" do

  before do
    User.destroy_all
  end

  it "Filling form" do
    visit '/'
    within(".form-horizontal") do
      fill_in 'user_login', :with => 'john'
      fill_in 'user_first_name', :with => 'John'
      fill_in 'user_last_name', :with => 'Doe'
      fill_in 'server_name', :with => 'localhost'
    end

    click_button(I18n::t('user.send_config'))
    current_path.should eq user_login_path
    page.should have_selector('#user_login')
  end

end

describe "Login process" do

  describe "Unsuccessful" do
    it "Redirects to login page" do
      visit '/'
      within(".form-horizontal") do
        fill_in 'user_login', :with => 'john'
        fill_in 'user_password', :with => 'karawany'
      end
      click_button(I18n::t('user.login'))
      current_path.should eq user_login_path
    end
  end

  describe "Successful" do

    before :each do
      MessagesController.any_instance.stub(:open_imap_session)
      FoldersController.any_instance.stub(:open_imap_session)
      FoldersController.any_instance.stub(:refresh).and_return
    end

    it "Seccessful and go to configure folders" do

      visit '/'

      within(".form-horizontal") do
        fill_in 'user_login', :with => 'john'
        fill_in 'user_password', :with => 'karawany'
      end

      click_button(I18n::t('user.login'))

      # current_path.should eq folders_path
      # puts current_path
      # click_button('Odśwież')
      # puts current_path
      # puts page.html
      # select('INBOX', :from => 'multiselect_form')
      # click_button('Pokaż/Ukryj')
      # has_xpath?('//li/a[@href=/folders/select/INBOX]')
    end

    it "Goes to notes tab" do
      visit '/'
      within(".form-horizontal") do
        fill_in 'user_login', :with => 'john'
        fill_in 'user_password', :with => 'karawany'
      end
      click_button(I18n::t('user.login'))
      visit '/notes'
      current_path.should eq notes_path
    end

  end # Successful


end

