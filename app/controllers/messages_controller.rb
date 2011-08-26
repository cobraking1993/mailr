require 'imap_session'
require 'imap_mailbox'
require 'imap_message'
require 'mail'

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
                Message.createForUser(@current_user,@current_folder,m)
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

        @attachments = []
        @render_as_text = []

        @message = @current_user.messages.find_by_uid(params[:id])
        @message.update_attributes(:unseen => false)
        imap_message = @mailbox.fetch_body(@message.uid)
        parts = imap_message.split(/\r\n\r\n/)
        @message_header = parts[0]
        @mail = Mail.new(imap_message)
        if @mail.multipart?
#            idx = 0
#            @mail.parts.each do |part|
#                a = Attachment.new( :message_id => @message.id,
#                                    :description => part.content_description,
#                                    :type => part.content_type,
#                                    :content => part.body.raw_source,
#                                    :encoding => part.content_transfer_encoding,
#                                    :idx => idx,
#                                    :multipart => part.multipart?
#                                    )
#                logger.custom('a',a.to_s)
#                if a.isText?
#                    @render_as_text << a.content_normalized
#                else
#                    @attachments << a
#                end
#
#                idx += 1
#            end
            Attachment.fromPart(@attachments,@message.id,@mail.parts,0)
            @attachments.each do |a|
                a.isText? ? @render_as_text << a.content_normalized : @render_as_text
            end

        else
            a = Attachment.new( :message_id => @message.id,
                                    :description => @mail.content_description,
                                    :type => @mail.content_type,
                                    :encoding => @mail.body.encoding,
                                    :charset => @mail.body.charset,
                                    :content => @mail.body.raw_source,
                                    :idx => 0
                                    )
            logger.custom('a',a.to_s)
            if a.isText?
                @render_as_text << a.content_normalized
            else
                @attachments << a
            end
        end
    end

    def body
        message = @mailbox.fetch_body(params[:id].to_i)
        mail = Mail.new(message)
        @title = ''
        @body = ''
        #
        #header = parts[0]
        #body = parts[1]
        #@body = "<html><head><title>ala</title><body><pre>#{header}</pre>#{mail.inspect}</body></html>"
        render 'mail_view',:layout => 'mail_view'
    end

    def attachment
        @message = @current_user.messages.find(params[:id])
        mail = Mail.new(@mailbox.fetch_body(@message.uid))

        if mail.multipart?
            part = mail.parts[params[:idx].to_i]
            a = Attachment.new( :message_id => @message.id,
                                :description => part.content_description,
                                :type => part.content_type,
                                :content => part.body.raw_source,
                                :encoding => part.content_transfer_encoding,
                                :idx => params[:idx]
                            )
        else
            a = Attachment.new( :message_id => @message.id,
                                    :type => mail.content_type,
                                    :encoding => mail.body.encoding,
                                    :charset => mail.body.charset,
                                    :content => mail.body.raw_source,
                                    :idx => 0
                                    )
        end
        headers['Content-type'] = a.type
        headers['Content-Disposition'] = %(attachment; filename="#{a.name}")
        render :text => a.decode
    end

end
