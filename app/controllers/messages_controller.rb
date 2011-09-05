require 'imap_session'
require 'imap_mailbox'
require 'imap_message'
require 'mail'
require 'mail_plugin_extension'

class MessagesController < ApplicationController

	include ImapMailboxModule
	include ImapSessionModule
	include ImapMessageModule
    include MessagesHelper

	before_filter :check_current_user ,:selected_folder,:get_current_folders

	before_filter :open_imap_session, :select_imap_folder

	before_filter :prepare_compose_buttons, :only => [:compose]

	#before_filter :mail_defaults, :only => [:sendout_or_save]

	before_filter :get_system_folders, :only => [:index]

	after_filter :close_imap_session

	theme :theme_resolver

	def index

        if @sent_folder.nil? || @drafts_folder.nil? || @inbox_folder.nil? || @trash_folder.nil?
            flash[:warning] = t(:not_all_configured,:scope => :folder)
        end

        if @current_folder.nil?
            flash[:warning] = t(:no_selected,:scope => :folder)
            redirect_to :controller => 'folders', :action => 'index'
            return
        end

        @messages = []

        folder_status = @mailbox.status
        @current_folder.update_attributes(:total => folder_status['MESSAGES'], :unseen => folder_status['UNSEEN'])

        folder_status['MESSAGES'].zero? ? uids_remote = [] : uids_remote = @mailbox.fetch_uids
        uids_local = @current_user.messages.where(:folder_id => @current_folder).collect(&:uid)

        logger.custom('current_folder',@current_folder.inspect)
        logger.custom('uids_local',uids_local.join(","))
        logger.custom('uids_remote',uids_remote.join(","))
        logger.custom('to_delete',(uids_local-uids_remote).join(","))
        logger.custom('to_fetch',(uids_remote-uids_local).join(","))

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
        if params[:message]
            @message = update_attributes(params[:message])
        end
	end

    def show
		@images = []
		@attachments = []
        @text_part = nil
        @html_part = nil

        @message = @current_user.messages.find_by_uid(params[:id])
        @message.update_attributes(:unseen => false)
        imap_message = @mailbox.fetch_body(@message.uid)

        mail = Mail.new(imap_message)
        @plain_header = mail.header.to_s
        @from = mail.From.addrs
        @to = mail.To.addrs
        @cc = mail.Cc
        @bcc = mail.Bcc
        @subject = mail.Subject
        @date = mail.date

        if mail.multipart? == true
            if not mail.text_part.nil?
                @text_part = mail.text_part.decoded_and_charseted
            end
            if not mail.html_part.nil?
                @html_part = mail.html_part.decoded_and_charseted
            end
            attachments = mail.attachments
            if not attachments.size.zero?
                for idx in 0..attachments.size - 1
                    a = attachments[idx]
                    a.idx = idx
                    a.parent_id = @message.uid
                    if a.isImage?
                        @images << a
                    else
                       @attachments << a
                    end
                end
            end
        else
            part = Mail::Part.new(mail)
            part.idx = 0
            part.parent_id = @message.uid
            if part.isText?
                @text_part = part.decoded_and_charseted
            elsif part.isImage?
                @images << part
            elsif part.isHtml?
                @html_part = part.decoded_and_charseted
            else
                @attachments << part
            end
        end
    end

    def html_body
        message = @current_user.messages.find(params[:id])
        mail = Mail.new(@mailbox.fetch_body(message.uid))
        if mail.multipart?
            @body = mail.html_part.decoded_and_charseted
        else
            @body = mail.decoded_and_charseted
        end
        if @body.nil?
            @body = t(:no_body,:scope=>:message)
        end
        render 'html_body',:layout => 'html_body'
    end

    def attachment
        attachments = []
        message = @current_user.messages.find(params[:id])
        mail = Mail.new(@mailbox.fetch_body(message.uid))
        if mail.multipart? == true
            attachments = mail.attachments
        else
            attachments << Mail::Part.new(mail)
        end
        a = attachments[params[:idx].to_i]
        headers['Content-type'] = a.main_type + "/" +  a.sub_type
        headers['Content-Disposition'] = %(attachment; filename="#{a.filename}")
        render :text => a.decoded
    end

    ############################################# protected section ##########################################

    protected

end
