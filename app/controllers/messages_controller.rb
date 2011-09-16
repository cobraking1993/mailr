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
	before_filter :get_system_folders, :only => [:index]
	before_filter :create_message_with_params, :only => [:compose]
	before_filter :prepare_multi1_buttons, :only => [:index,:show]
	before_filter :prepare_multi2_buttons, :only => [:index]
	before_filter :prepare_multi3_buttons, :only => [:show]
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
		#before filter :prepare_compose_buttons, :create_message_with_params
        @operation = :new
        if params["cid"].present?
            contact = @current_user.contacts.find_by_id(params["cid"])
            if not contact.nil?
                @message.to_addr = contact.email
            end
        elsif params["cids"].present?
            contacts = []
            params["cids"].each do |c|
                contact = @current_user.contacts.find_by_id(c)
                if not contact.nil?
                    contacts << contact.email
                end
            end
            @message.to_addr = contacts.join(';')
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


		# FIXME missing fields and support arrays
        #@from = mail.From.addrs.presence
        #@to = mail.To.addrs.presence
        @from = @message.from_addr
        @to = @message.to_addr
        @cc = mail.Cc.presence
        @bcc = mail.Bcc.presence
        #@subject = mail.Subject
        @date = mail.date.presence

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
                    if a.isImage? and @current_user.prefs.msg_image_view_as.to_sym.eql?(:thumbnail)
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
            elsif part.isImage? and @current_user.prefs.msg_image_view_as.to_sym.eql?(:thumbnail)
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
        else
            if @body=~/cid:([\w@\.]+)/
                attachments = mail.attachments
                if not attachments.size.zero?
                for idx in 0..attachments.size - 1
                    @body.gsub!(/cid:#{attachments[idx].cid}/,messages_attachment_download_path(message.uid,idx))
                end
            end
            end
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

    def prepare_multi2_buttons
        @multi2_buttons = []
        @multi2_buttons << {:text => 'trash',:scope=>:message,:image => 'trash.png'}
        @multi2_buttons << {:text => 'set_unread',:scope=>:message,:image => 'unseen.png'}
        @multi2_buttons << {:text => 'set_read',:scope=>:message,:image => 'seen.png'}
    end

    def prepare_multi1_buttons
        @multi1_buttons = []
        @multi1_buttons << {:text => 'copy',:scope=>:message,:image => 'copy.png'}
        @multi1_buttons << {:text => 'move',:scope=>:message,:image => 'move.png'}
    end

    def prepare_multi3_buttons
        @multi3_buttons = []
        @multi3_buttons << {:text => 'show_header',:scope=>:show,:image => 'zoom.png'}
        @multi3_buttons << {:text => 'trash',:scope=>:show,:image => 'trash.png'}
        @multi3_buttons << {:text => 'reply',:scope=>:show,:image => 'reply.png'}
    end
end
