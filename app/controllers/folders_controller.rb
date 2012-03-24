require 'imap_mailbox'
require 'imap_session'

class FoldersController < ApplicationController

	include ImapMailboxModule
	include ImapSessionModule

	before_filter :check_current_user,:selected_folder, :get_current_folders

	before_filter :open_imap_session, :except => [:index,:show_hide,:system]
	after_filter :close_imap_session, :except => [:index,:show_hide,:system]

	before_filter :get_folders
	#before_filter :prepare_buttons_to_folders

	#theme :theme_resolver

    def index
        #before_filter
    end

    def create
        if params[:folder][:target].empty?
            flash[:warning] = t(:to_create_empty,:scope=>:folder)
            render "index"
        else
            begin
                #TODO recreate local copy of folders
                if params[:folder][:parent].empty?
                    @mailbox.create_folder(params[:folder][:target])
                else
                    parent_folder = @current_user.folders.find(params[:folder][:parent])
                    if parent_folder.depth >= $defaults["mailbox_max_parent_folder_depth"].to_i
                        raise Exception, t(:max_depth,:scope=>:folder)
                    end
                    @mailbox.create_folder(parent_folder.full_name + parent_folder.delim + params[:folder][:target])
                end
            rescue Exception => e
                flash[:error] = t(:can_not_create,:scope=>:folder) + ' (' + e.to_s + ')'
                render 'index'
                return
            end
            flash[:success] = t(:was_created,:scope=>:folder)
            redirect_to :action => 'index'
        end
    end

    def delete
        if params[:folder][:delete].empty?
            flash[:warning] = t(:to_delete_empty,:scope=>:folder)
            render "index"
        else
            begin
                folder = @current_user.folders.find(params[:folder][:delete])
                if @folders_system.include?(folder)
                    raise Exception, t(:system,:scope=>:folder)
                end
                @mailbox.delete_folder(folder.full_name)
                if @current_folder.eql? folder
                    session[:selected_folder] = nil
                end
                folder.destroy
            rescue Exception => e
                flash[:error] = t(:can_not_delete,:scope=>:folder) + ' (' + e.to_s + ')'
                render 'index'
                return
            end
            flash[:success] = t(:was_deleted,:scope=>:folder)
            redirect_to :action => 'index'
        end
    end

    def system
        logger.custom('sss',params[:folder].inspect)
        @folders.each do |f|
        logger.custom('s',f.inspect)
            if f.isSystem?
                f.setNone
            end
            if f.id == params[:folder][:mailbox_inbox].to_i
                f.setInbox
            end
            if f.id == params[:folder][:mailbox_sent].to_i
                f.setSent
            end
            if f.id == params[:folder][:mailbox_trash].to_i
                f.setTrash
            end
            if f.id == params[:folder][:mailbox_drafts].to_i
                f.setDrafts
            end
        end
        redirect_to :action => 'index'
    end

	def refresh
	# TODO save system folders
        if params[:refresh]
            Folder.refresh(@mailbox,@current_user)
            flash.keep
        elsif params[:show_hide]
            if !params["folders_to_show"].nil?
                @folders.each do |f|
                    if params["folders_to_show"].include?(f.id.to_s)
                        f.shown = true
                        f.save
                    else
                        f.shown = false
                        f.save
                    end
                end
            end
        end
        redirect_to :action => 'index'
	end

	def select
        session[:selected_folder] = params[:id]
        redirect_to :controller => 'messages', :action => 'index'
	end

	def refresh_status
        @folders_shown.each do |f|
            @mailbox.set_folder(f.full_name)
            folder_status = @mailbox.status
            f.update_attributes(:total => folder_status['MESSAGES'], :unseen => folder_status['UNSEEN'])
        end
        redirect_to :controller=> 'messages', :action => 'index'
	end

	def emptybin
        begin
            trash_folder = @current_user.folders.trash.first
            if trash_folder.nil?
                raise Exception, t(:not_configured_trash,:scope=>:folder)
            end
            @mailbox.set_folder(trash_folder.full_name)
            trash_folder.messages.each do |m|
                @mailbox.delete_message(m.uid)
            end
            @mailbox.expunge
            trash_folder.messages.destroy_all
            trash_folder.update_attributes(:unseen => 0, :total => 0)
        rescue Exception => e
            flash[:error] = "#{t(:imap_error,:scope=>:common)} (#{e.to_s})"
        end
        redirect_to :controller => 'messages', :action => 'index'
	end


	############################################# protected section #######################################

    protected

    #def prepare_buttons_to_folders
		#@buttons = []
        #@buttons << {:text => 'show_hide',:scope=>'folder',:image => 'flag.png'}
        #@buttons << {:text => 'refresh',:scope=>'folder',:image => 'refresh.png'}
	#end

    def get_folders
        @folders = @current_user.folders
        @folders_shown = @current_user.folders.shown
        @folders_system = @current_user.folders.sys
        @current_user.folders.inbox.first.nil? ? @folder_inbox = "" : @folder_inbox = @current_user.folders.inbox.first.id
        @current_user.folders.drafts.first.nil? ? @folder_drafts = "" : @folder_drafts = @current_user.folders.drafts.first.id
        @current_user.folders.sent.first.nil? ? @folder_sent = "" : @folder_sent = @current_user.folders.sent.first.id
        @current_user.folders.trash.first.nil? ? @folder_trash = "" : @folder_trash = @current_user.folders.trash.first.id
    end

end
