require 'tempfile'

class LinksController < ApplicationController

	before_filter :check_current_user,:selected_folder, :get_current_folders

	before_filter :get_links, :only => [:index]

    def index

    end

    def new
        @link = Link.new
    end

    def edit
        @link = @current_user.links.find(params[:id])
        render 'edit'
    end

    def create
				if params["delete_selected"]
					if params["items_ids"]
						params["items_ids"].each do |id|
							@current_user.links.find_by_id(id).destroy
						end
					end
					redirect_to(links_path)
					return
        end
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

    def import_export
        if params["export"]
					links = @current_user.links
					s = ""
					links.each do |l|
            s += l.export + "\r\n"
					end
					headers['Content-type'] = "text/csv"
					headers['Content-Disposition'] = %(attachment; filename="links.csv")
					render :text => s
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

    ####################################### protected section ################################

    protected

    ####################################### private section ##################################

    private

    def get_links
        @links = Link.getPageForUser(@current_user,params[:page],params[:sort_field],params[:sort_dir])
    end

end
