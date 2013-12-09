require 'tempfile'

class ContactsController < ApplicationController

  before_filter :check_current_user,:selected_folder, :get_current_folders

  before_filter :get_contacts, :only => [:index]

  def index

  end

  #problem http://binary10ve.blogspot.com/2011/05/migrating-to-rails-3-got-stuck-with.html
  #def destroy
  #    @current_user.contacts.find(params[:id]).destroy
  #    redirect_to(contacts_path)
  #end

  def new
    @contact = Contact.new
  end

  def edit
    @contact = @current_user.contacts.find(params[:id])
    render 'edit'
  end

  def create
    if params["compose_to_selected"]
      if params["items_ids"]
        redirect_to compose_path(:cids => params["items_ids"])
        return
      end
    end
    if params["delete_selected"]
      if params["items_ids"]
        params["items_ids"].each do |id|
          @current_user.contacts.find_by_id(id).destroy
        end
      end
      redirect_to(contacts_path)
      return
    end
    @contact = @current_user.contacts.build(params[:contact])
    if @contact.valid?
      @contact.save
      flash[:success] = t(:was_created,:scope=>:contact)
      redirect_to(contacts_path)
    else
      render 'new'
    end
  end

  def update
    @contact = @current_user.contacts.find(params[:id])
    if @contact.update_attributes(params[:contact])
      redirect_to(contacts_path)
    else
      render 'edit'
    end
  end

  def import_export
    if params["export"]
      contacts = @current_user.contacts
      s = ""
      contacts.each do |c|
        s += c.export + "\r\n"
      end
      headers['Content-type'] = "text/csv"
      headers['Content-Disposition'] = %(attachment; filename="contacts.csv")
      render :text => s
      return
    elsif params["import"]
      begin
        raise t(:no_file_chosen,:scope=>:common) if not params[:upload]
        raise t(:no_tmp_dir,:scope=>:common) if not File.exists?($defaults["msg_upload_dir"])
        tmp_file = Tempfile.new($defaults["contact_tmp_filename"],$defaults["msg_upload_dir"])
        tmp_file.write(params[:upload][:datafile].read.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: ''))
        tmp_file.flush
        tmp_file.rewind
        tmp_file.readlines.each do |line|
          next if line =~ /^#/
            Contact.import(@current_user,line)
        end
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = {:title => e.to_s,:info => e.record.inspect + e.record.errors.inspect}
      rescue Exception => e
        flash[:error] = e.to_s
      else
        flash[:success] = t(:were_imported,:scope=>:contact)
      end
    end
    redirect_to :action => 'index'
  end

  ####################################### protected section ################################

  protected

  ####################################### private section ##################################

  private

  def get_contacts
    @contacts = Contact.getPageForUser(@current_user,params[:page],params[:sort_field],params[:sort_dir])
  end

end
