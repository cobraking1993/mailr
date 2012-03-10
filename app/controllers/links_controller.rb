require 'tempfile'

class LinksController < ApplicationController

	before_filter :check_current_user,:selected_folder, :get_current_folders

	before_filter :get_links, :only => [:index]

	before_filter :prepare_ops_buttons, :only => [:index]

	#, :prepare_export_import_buttons,:only => [:index]

	#theme :theme_resolver

    def index

    end

    def ops
        if params["create_new"]
            redirect_to(new_link_path)
            return
        end
        if !params["ids"]
            flash[:warning] = t(:no_selected,:scope=>:link)
        else
            if params["delete_selected"]
                params["ids"].each do |id|
                    @current_user.links.find_by_id(id).destroy
                end
            end
        end
        redirect_to(links_path)
    end

    #problem http://binary10ve.blogspot.com/2011/05/migrating-to-rails-3-got-stuck-with.html
    #def destroy
    #    @current_user.contacts.find(params[:id]).destroy
    #    redirect_to(contacts_path)
    #end

    def new
        @link = Link.new
    end

    def edit
        @link = @current_user.links.find(params[:id])
        render 'edit'
    end

    def create
        @link = @current_user.links.build(params[:link])
        if @link.valid?
            @link.save
            flash[:success] = t(:was_created,:scope=>:link)
            redirect_to(links_path)
        else
            render 'new'
        end
    end

    def update
        @link = @current_user.links.find(params[:id])
        if @link.update_attributes(params[:link])
            redirect_to(links_path)
        else
            render 'edit'
        end
    end

    def external
        if params["export"]
            redirect_to :action => 'export'
            return
        elsif params["import"]
            begin
                raise t(:no_file_chosen,:scope=>:common) if not params[:upload]
                raise t(:no_tmp_dir,:scope=>:common) if not File.exists?($defaults["msg_upload_dir"])
                tmp_file = Tempfile.new($defaults["contact_tmp_filename"],$defaults["msg_upload_dir"])
                tmp_file.write(params[:upload][:datafile].read)
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

    def export
        contacts = @current_user.contacts
        s = ""
        contacts.each do |c|
            s += c.export + "\r\n"
        end
        headers['Content-type'] = "text/csv"
        headers['Content-Disposition'] = %(attachment; filename="contacts.csv")
        render :text => s
    end

    ####################################### protected section ################################

    protected

    def prepare_ops_buttons
        @buttons = []
        @buttons << {:text => 'create_new',:scope=> 'link', :image => 'plus.png'}
        @buttons << {:text => 'delete_selected',:scope=>'link',:image => 'minus.png'}
    end

    def prepare_export_import_buttons
        @ei_buttons = []
        @ei_buttons << {:text => 'import',:scope=>'link',:image => 'right.png'}
        @ei_buttons << {:text => 'export',:scope=>'link',:image => 'left.png'}
    end

    ####################################### private section ##################################

    private

    def get_links
        @links = Link.getPageForUser(@current_user,params[:page],params[:sort_field],params[:sort_dir])
    end

end
