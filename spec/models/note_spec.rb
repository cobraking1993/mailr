require 'spec_helper'

describe Note do

  before :all do
    User.destroy_all
    @user = User.create!(:first_name => 'John', :last_name => 'Doe', :login => 'john')
  end

  let(:note_body) {"Lorem ipsum dolor sit amet, consectetuer adipiscing elit."}
  let(:long_body) {1001*"x"}
  let(:note_title) {"Some title"}

  it "is not assign to user" do
    @user.notes.count.should == 0
  end

  it "creates" do
    expect{ @user.notes.create!(:body => note_body, :title => note_title) }.to change{ @user.notes.count }.by 1
  end

  it "empty body of note raise exception" do
    expect{ @user.notes.create!(:body => "", :title => note_title) }.to raise_error{ ActiveRecord::RecordInvalid }
  end

  it "too long body of note raise exception" do
    expect{ @user.notes.create!(:body => long_body, :title => note_title) }.to raise_error{ ActiveRecord::RecordInvalid }
  end

  it "does not create note for user with empty title" do
    expect{ @user.notes.create!(:body => "qwerty") }.to raise_error{ ActiveRecord::RecordInvalid }
  end

  it "deletes when user deletes" do
    @user.destroy
    Note.all.count.should == 0
  end

end


