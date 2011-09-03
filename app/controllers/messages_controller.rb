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

	before_filter :prepare_buttons, :only => [:compose,:reply,:edit,:sendout_or_save]

	#before_filter :mail_defaults, :only => [:sendout_or_save]

	before_filter :get_system_folders, :only => [:index,:ops,:sendout_or_save]

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

	def reply

        attachments = []
        body = ''

        old_message = @current_user.messages.find(params[:id])
        @message = Message.new
        @message.to_addr = address_formatter(old_message.from_addr,:raw)
        @message.subject = old_message.subject
        @reply = true
        imap_message = @mailbox.fetch_body(old_message.uid)
        mail = Mail.new(imap_message)
        if mail.multipart?
            Attachment.fromMultiParts(attachments,old_message.id,mail.parts)
        else
			Attachment.fromSinglePart(attachments,old_message.id,mail)
		end

		for idx in 0..attachments.size-1
			if attachments[idx].isText?
                body << attachments[idx].decode_and_charset
                break
			end
		end
		@message.body = body
        render 'compose'
	end

	def edit

        attachments = []
        body = ''

        old_message = @current_user.messages.find(params[:id])
        @message = Message.new
        @message.to_addr = address_formatter(old_message.to_addr,:raw)
        @message.subject = old_message.subject
        imap_message = @mailbox.fetch_body(old_message.uid)
        mail = Mail.new(imap_message)
        if mail.multipart?
            Attachment.fromMultiParts(attachments,old_message.id,mail.parts)
        else
			Attachment.fromSinglePart(attachments,old_message.id,mail)
		end

		for idx in 0..attachments.size-1
			if attachments[idx].isText?
                body << attachments[idx].decode_and_charset
                break
			end
		end
		@message.body = body
        render 'compose'
	end

	def sendout_or_save

        mail = Mail.new
        mail.subject = params[:message][:subject]
        mail.from = @current_user.full_address
        mail.to = params[:message][:to_addr]
        mail.body = params[:message][:body]
        #mail.add_file :filename => 'somefile.png', :content => File.read('/tmp/script_monitor_20110810143216.log')

        if params[:send]
            smtp_server = @current_user.servers.primary_for_smtp

            if smtp_server.nil?
                flash[:error] = t(:not_configured_smtp,:scope => :compose)
                @message = Message.new
                    if params[:message]
                        @message = update_attributes(params[:message])
                    end
                render 'compose'
                return
            end

            begin

            set_mail_defaults(@current_user,smtp_server,session)
            #logger.custom('mail',Mail.delivery_method.inspect)

            @response = mail.deliver!
            #logger.custom('response',@response.inspect)

            if @sent_folder.nil?
                raise t(:not_configured_sent,:scope=>:compose)
            end
            @mailbox.append(@sent_folder.full_name,mail.to_s,[:Seen])

            rescue Exception => e
                flash[:error] = "#{t(:imap_error)} (#{e.to_s})"
                redirect_to :action => 'index'
                return
            end
            flash[:notice] = t(:was_sent,:scope => :compose)
            redirect_to :action => 'index'
        elsif params[:save_as_draft]
            begin
                if @drafts_folder.nil?
                    raise t(:not_configured_drafts,:scope=>:compose)
                end
                # TODO delete old one if was edit
                @mailbox.append(@drafts_folder.full_name,mail.to_s,[:Seen])
            rescue Exception => e
                flash[:error] = "#{t(:imap_error)} (#{e.to_s})"
                redirect_to :action => 'index'
                return
            end
            flash[:notice] = t(:was_saved,:scope => :compose)
            redirect_to :action => 'index'
        end
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
            if not @trash_folder.nil?
                params["uids"].each do |uid|
                    @mailbox.move_message(uid,@trash_folder.full_name)
                    message = @current_folder.messages.find_by_uid(uid)
                    message.change_folder(@trash_folder)
                end
                @mailbox.expunge
                @trash_folder.update_stats
                @current_folder.update_stats
            end
        elsif params["copy"]
            if params[:folder][:target].empty?
                flash[:warning] = t(:no_selected,:scope=>:folder)
            else
                dest_folder = @current_user.folders.find(params[:folder][:target])
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
            if params[:folder][:target].empty?
                flash[:warning] = t(:no_selected,:scope=>:folder)
            else
                dest_folder = @current_user.folders.find(params[:folder][:target])
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


        #@attachments = []
        #logger.custom('after_parse',Time.now)
       #if mail.multipart?
        #    Attachment.fromMultiParts(@attachments,@message.id,@mail.parts)
        #else
	#		Attachment.fromSinglePart(@attachments,@message.id,@mail)
#		end
		#logger.custom('attach',Time.now)

#		for idx in 0..@attachments.size-1
#            @attachments[idx].idx = idx
#			@attachments[idx].isText? ? @render_as_text << @attachments[idx].decode_and_charset : @render_as_text
#			@attachments[idx].isHtml? ? @render_as_html_idx ||= idx : @render_as_html_idx
#            @attachments[idx].isImageAndNotCid? ? @images <<  @attachments[idx] : @images
#		end
		#logger.custom('done',Time.now)
		#@attachments = @mail.attachments
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

    def body
		attachments = []
		cids = []
		message = @current_user.messages.find(params[:id])
        mail = Mail.new(@mailbox.fetch_body(message.uid))

		if mail.multipart?
            Attachment.fromMultiParts(attachments,message.id,mail.parts)
        else
			Attachment.fromSinglePart(attachments,message.id,mail)
		end
		html = attachments[params[:idx].to_i]

		@body = html.decode_and_charset

		for idx in 0..attachments.size-1
			if not attachments[idx].cid.size.zero?
			@body.gsub!(/cid:#{attachments[idx].cid}/,messages_attachment_download_path(message.uid,idx))
			end
		end

        render 'html_view',:layout => 'html_view'
    end

    def attachment
		attachments = []
        message = @current_user.messages.find(params[:id])
        mail = Mail.new(@mailbox.fetch_body(message.uid))
		if mail.multipart?
            Attachment.fromMultiParts(attachments,message.id,mail.parts)
        else
			Attachment.fromSinglePart(attachments,message.id,mail)
		end
		a = attachments[params[:idx].to_i]
        headers['Content-type'] = a.type
        headers['Content-Disposition'] = %(attachment; filename="#{a.name}")
        render :text => a.decode
    end

    ############################################# protected section ##########################################

    def prepare_buttons
        @buttons = []
        @buttons << {:text => 'send',:image => 'tick.png'}
        @buttons << {:text => 'save_as_draft',:image => 'tick.png'}
    end

    def set_mail_defaults(user,server,session)
        if server.auth.nil? or server.auth == 'none'
            password = nil
            authentication = nil
            enable_starttls_auto = nil
            openssl_verify_mode = nil
            user_name = nil
        else
            password = user.get_cached_password(session)
            authentication = server.auth
            enable_starttls_auto = server.use_tls
            openssl_verify_mode = OpenSSL::SSL::VERIFY_NONE
            user_name = user.full_address
        end
		Mail.defaults do
			delivery_method :smtp, {:address => server.name,
									:port => server.port,
									:domain => user.domain,
									:user_name => user_name,
									:password => password,
									:authentication => authentication,
									:enable_starttls_auto =>  enable_starttls_auto,
									:openssl_verify_mode => openssl_verify_mode
									}
		end
    end

    def get_system_folders
        @drafts_folder = @current_user.folders.drafts.first
        @sent_folder = @current_user.folders.sent.first
        @inbox_folder = @current_user.folders.inbox.first
        @trash_folder = @current_user.folders.trash.first
    end

end
