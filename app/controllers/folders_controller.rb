require 'imap_mailbox'
require 'imap_session'

class FoldersController < ApplicationController

    include ImapMailboxModule
	include ImapSessionModule

	before_filter :check_current_user ,:selected_folder

	before_filter :open_imap_session, :except => [:index,:refresh_status,:show_hide]
	after_filter :close_imap_session, :except => [:index,:refresh_status,:show_hide]

	before_filter :get_folders

	theme :theme_resolver

    def index

    end

    def create
        if params["folder"].empty?
            flash[:warning] = t(:to_create_empty,:scope=>:folder)
            render "index"
        else
            begin
                if params["parent_folder"].empty?
                    @mailbox.create_folder(params[:folder])
                else
                    parent_folder = @current_user.folders.find(params["parent_folder"])
                    if parent_folder.depth >= $defaults["mailbox_max_parent_folder_depth"].to_i
                        raise Exception, t(:max_depth,:scope=>:folder)
                    end
                    @mailbox.create_folder(parent_folder.full_name + parent_folder.delim + params[:folder])
                end
            rescue Exception => e
                flash[:error] = t(:can_not_create,:scope=>:folder) + ' (' + e.to_s + ')'
                render 'index'
                return
            end
            redirect_to :action => 'refresh', :flash => t(:was_created,:scope=>:folder), :type => :notice
        end
    end
    # FIXME if you delete folder you should change current folder because if you go to messages/index you got nil
    def delete
        if params["folder"].empty?
            flash[:warning] = t(:to_delete_empty,:scope=>:folder)
            render "index"
        else
            begin
                folder = @current_user.folders.find(params["folder"])
                system_folders = Array.new
                system_folders << $defaults["mailbox_inbox"]
                system_folders << $defaults["mailbox_trash"]
                system_folders << $defaults["mailbox_sent"]
                system_folders << $defaults["mailbox_drafts"]
                if system_folders.include?(folder.full_name.downcase)
                    raise Exception, t(:system_folder)
                end
                @mailbox.delete_folder(folder.full_name)
            rescue Exception => e
                flash[:error] = t(:can_not_delete,:scope=>:folder) + ' (' + e.to_s + ')'
                render 'index'
                return
            end
            redirect_to :action => 'refresh', :flash => t(:was_deleted,:scope=>:folder), :type => :notice
        end
    end

    def show_hide
		@folders.each do |f|
		logger.info f.inspect,"\n"
			if params["folders_to_show"].include?(f.id.to_s)
				f.shown = true
				f.save
			else
				f.shown = false
				f.save
			end
		end
        redirect_to :action => 'index'
    end

	def refresh
		Folder.refresh(@mailbox,@current_user)
		flash.keep
		redirect_to :action => 'index'
	end

    protected

    def get_folders
        @folders = @current_user.folders.order("name asc")
        @folders_shown = []
        @folders.each do |f|
			if f.shown == true
				@folders_shown << f
			end
			if f.selected?(@selected_folder)
				@current_folder = f
			end
        end
    end

end
