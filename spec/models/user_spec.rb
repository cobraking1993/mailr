require 'spec_helper'

describe User do

  before :all do
    User.destroy_all
    $defaults ||= YAML::load(File.open(Rails.root.join('config','settings.yml')))
  end

  it "creating" do
    @user = User.create!(:first_name => 'John', :last_name => 'Doe', :login => 'john1')
  end

  it "not creating when invalid fields" do
    expect{ @user.create!() }.to raise_error{ ActiveRecord::RecordInvalid }
  end

  it "creating servers config" do
    @user = User.create!(:first_name => 'John', :last_name => 'Doe', :login => 'john2')
    Server.create_server(@user,'localhost')
    @user.servers.collect(&:name).should == ["localhost", "localhost"]
  end

  it "creating prefs config" do
    @user = User.create!(:first_name => 'John', :last_name => 'Doe', :login => 'john3')
    Prefs.create_default(@user)
    @user.prefs.theme.should == 'bootstrap_tweeter'
  end

end
