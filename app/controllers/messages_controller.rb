require 'imap_session'
require 'imap_mailbox'
require 'imap_message'

class MessagesController < ApplicationController

	include ImapMailboxModule
	include ImapSessionModule
	include ImapMessageModule
    include MessagesHelper

	before_filter :check_current_user ,:selected_folder,:get_current_folders

	before_filter :open_imap_session, :select_imap_folder
	after_filter :close_imap_session

	theme :theme_resolver

	def index

        if @current_folder.nil?
            redirect_to :controller => 'folders', :action => 'index'
            return
        end

        @messages = []

        folder_status = @mailbox.status
        @current_folder.update_attributes(:total => folder_status['MESSAGES'], :unseen => folder_status['UNSEEN'])

        folder_status['MESSAGES'].zero? ? uids_remote = [] : uids_remote = @mailbox.fetch_uids
        uids_local = @current_user.messages.where(:folder_id => @current_folder).collect(&:uid)

        (uids_local-uids_remote).each do |uid|
            @current_folder.messages.find_by_uid(uid).destroy
        end

        (uids_remote-uids_local).each_slice($defaults["imap_fetch_slice"].to_i) do |slice|
            messages = @mailbox.uid_fetch(slice, ImapMessageModule::IMAPMessage.fetch_attr)
            messages.each do |m|
                mess = ImapMessageModule::IMAPMessage.fromImap(m)
                Message.createForUser(@current_user,@current_folder,mess)
            end
        end

        @messages = Message.getPageForUser(@current_user,@current_folder,params[:page],params[:sort_field],params[:sort_dir])

	end

	def compose
        @message = Message.new
	end

	def reply
        @message = Message.new
        render 'compose'
	end

	def sendout
        flash[:notice] = t(:was_sent,:scope => :sendout)
        redirect_to :action => 'index'
    end

    def msgops
        begin
            if !params["uids"]
                flash[:warning] = t(:no_selected,:scope=>:message)
            elsif params["reply"]
                redirect_to :action => 'reply', :id => params[:id]
                return
            end
        rescue Exception => e
            flash[:error] = "#{t(:imap_error)} (#{e.to_s})"
        end
        redirect_to :action => 'show', :id => params[:id]
    end

	def ops
        begin
        if !params["uids"]
            flash[:warning] = t(:no_selected,:scope=>:message)
        elsif params["set_unread"]
            params["uids"].each do |uid|
                @mailbox.set_unread(uid)
                @current_user.messages.find_by_uid(uid).update_attributes(:unseen => 1)
            end
        elsif params["set_read"]
            params["uids"].each do |uid|
                @mailbox.set_read(uid)
                @current_user.messages.find_by_uid(uid).update_attributes(:unseen => 0)
            end
        elsif params["trash"]
            dest_folder = @current_user.folders.find_by_full_name($defaults["mailbox_trash"])
            params["uids"].each do |uid|
                @mailbox.move_message(uid,dest_folder.full_name)
                message = @current_folder.messages.find_by_uid(uid)
                message.change_folder(dest_folder)
            end
            @mailbox.expunge
            dest_folder.update_stats
            @current_folder.update_stats
        elsif params["copy"]
            if params["dest_folder"].empty?
                flash[:warning] = t(:no_selected,:scope=>:folder)
            else
                dest_folder = @current_user.folders.find(params["dest_folder"])
                params["uids"].each do |uid|
                    @mailbox.copy_message(uid,dest_folder.full_name)
                    message = @current_folder.messages.find_by_uid(uid)
                    new_message = message.clone
                    new_message.folder_id = dest_folder.id
                    new_message.save
                end
                dest_folder.update_stats
                @current_folder.update_stats
            end
        elsif params["move"]
            if params["dest_folder"].empty?
                flash[:warning] = t(:no_selected,:scope=>:folder)
            else
                dest_folder = @current_user.folders.find(params["dest_folder"])
                params["uids"].each do |uid|
                    @mailbox.move_message(uid,dest_folder.full_name)
                    message = @current_folder.messages.find_by_uid(uid)
                    message.change_folder(dest_folder)
                end
                @mailbox.expunge
                dest_folder.update_stats
                @current_folder.update_stats
            end
        end
        rescue Exception => e
            flash[:error] = "#{t(:imap_error)} (#{e.to_s})"
        end
        redirect_to :action => 'index'
    end

    def show
        @message = @current_user.messages.find(params[:id])
        @message.update_attributes(:unseen => false)

    end

    def body
        body = @mailbox.fetch_body(params[:id].to_i)
        @body = "<html><head><title>ala</title><body>#{body}</body></html>"
        render :text => @body
    end

end
