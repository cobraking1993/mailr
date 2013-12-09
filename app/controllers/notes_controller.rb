require 'tempfile'

class NotesController < ApplicationController

  before_filter :check_current_user, :selected_folder, :get_current_folders

  def index
    @notes = Note.getPageForUser(@current_user,params[:page],params[:sort_field],params[:sort_dir])
  end

  def new
    @note = Note.new
  end

  def edit
    @note = @current_user.notes.find(params[:id])
  end

  def show
    @note = @current_user.notes.find(params[:id])
  end

  def create
    if params["delete_selected"]
      if params["items_ids"]
        params["items_ids"].each do |id|
          @current_user.notes.find_by_id(id).destroy
        end
      end
      redirect_to(notes_path)
      return
    end
    @note = @current_user.notes.build(params[:note])
    if @note.valid?
      @note.save
      flash[:success] = t(:was_created,:scope=>:note)
      redirect_to note_path @note
    else
      render 'new'
    end
  end

  def update
    @note = @current_user.notes.find(params[:id])
    if @note.update_attributes(params[:note])
      redirect_to note_path @note
    else
      render 'edit'
    end
  end

  def import_export
    if params["export"]
      notes = @current_user.notes
      s = ""
      notes.each do |l|
        s += l.export + "\r\n"
      end
      headers['Content-type'] = "text/csv"
      headers['Content-Disposition'] = %(attachment; filename="notes.csv")
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
            Link.import(@current_user,line)
        end
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = {:title => e.to_s,:info => e.record.inspect + e.record.errors.inspect}
      rescue Exception => e
        flash[:error] = e.to_s
      else
        flash[:success] = t(:were_imported,:scope=>:link)
      end
    end
    redirect_to :action => 'index'
  end

end
