require 'imap_session'
require 'imap_mailbox'
require 'imap_message'
require 'mail'

class MessagesOpsController < ApplicationController

    include ImapMailboxModule
	include ImapSessionModule
	include ImapMessageModule
	include MessagesHelper

    before_filter :check_current_user ,:selected_folder,:get_current_folders
    before_filter :open_imap_session, :select_imap_folder
    before_filter :prepare_compose_buttons
    before_filter :get_system_folders, :only => [:sendout_or_save,:single,:multi]
    after_filter :close_imap_session
    theme :theme_resolver


    ############################################### single #####################################

    def single
        if params[:reply]
            reply
            return
        elsif params[:trash]
            trash
        end
        redirect_to :controller => 'messages', :action => 'index'
    end

    ############################################### multi ######################################

    def multi
        begin
        if !params[:uids]
            flash[:warning] = t(:no_selected,:scope=>:message)
        elsif params[:set_unread]
            set_unread
        elsif params[:set_read]
            set_read
        elsif params[:trash]
            trash
        elsif params[:copy]
            copy
        elsif params[:move]
            move
        end
        rescue Exception => e
            flash[:error] = "#{t(:imap_error)} (#{e.to_s})"
        end
        redirect_to :controller => 'messages', :action => 'index'
    end

    def set_unread
        params["uids"].each do |uid|
            @mailbox.set_unread(uid)
            @current_user.messages.find_by_uid(uid).update_attributes(:unseen => 1)
        end
    end

    def set_read
        params["uids"].each do |uid|
            @mailbox.set_read(uid)
            @current_user.messages.find_by_uid(uid).update_attributes(:unseen => 0)
        end
    end

    def trash
        if @trash_folder.nil?
            flash[:warning] = t(:not_configured_trash, :scope=>:folder)
        else
            params["uids"].each do |uid|
                @mailbox.move_message(uid,@trash_folder.full_name)
                message = @current_folder.messages.find_by_uid(uid)
                message.change_folder(@trash_folder)
            end
            @mailbox.expunge
            @trash_folder.update_stats
            @current_folder.update_stats
        end
    end

    def copy
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
    end

    def move
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

    ############################################### sendout_or_save ############################

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
                render 'messages/compose'
                return
            end

            begin

            set_mail_defaults(@current_user,smtp_server,session)
            logger.custom('mail',Mail.delivery_method.inspect)

            @response = mail.deliver!
            logger.custom('response',@response.inspect)

            if @sent_folder.nil?
                raise t(:not_configured_sent,:scope=>:compose)
            end
            @mailbox.append(@sent_folder.full_name,mail.to_s,[:Seen])

            rescue Exception => e
                flash[:error] = "#{t(:imap_error)} (#{e.to_s})"
                redirect_to :controller => 'messages', :action => 'index'
                return
            end
            flash[:notice] = t(:was_sent,:scope => :compose)
            redirect_to :controller => 'messages', :action => 'index'
        elsif params[:save_as_draft]
            begin
                if @drafts_folder.nil?
                    raise t(:not_configured_drafts,:scope=>:compose)
                end
                # TODO delete old one if was edit
                @mailbox.append(@drafts_folder.full_name,mail.to_s,[:Seen])
            rescue Exception => e
                flash[:error] = "#{t(:imap_error)} (#{e.to_s})"
                redirect_to :controller => 'messages', :action => 'index'
                return
            end
            flash[:notice] = t(:was_saved,:scope => :compose)
            redirect_to :controller => 'messages', :action => 'index'
        end
    end

    ###################################### protected section #######################################

    protected

    def edit

        old_message = @current_user.messages.find(params[:id].first)
        @message = Message.new
        @message.to_addr = address_formatter(old_message.to_addr,:raw)
        @message.subject = old_message.subject
        imap_message = @mailbox.fetch_body(old_message.uid)
        @edit = true
        mail = Mail.new(imap_message)
        if mail.multipart?
            @message.body = mail.text_part.decoded_and_charseted
        else
            @message.body = mail.decoded_and_charseted
        end
        render 'messages/compose'
	end

    def reply
        old_message = @current_user.messages.find(params[:uids].first)
        @message = Message.new
        @message.to_addr = address_formatter(old_message.from_addr,:raw)
        @message.subject = old_message.subject

        imap_message = @mailbox.fetch_body(old_message.uid)
        mail = Mail.new(imap_message)
        if mail.multipart?
            @message.body = mail.text_part.decoded_and_charseted
        else
            @message.body = mail.decoded_and_charseted
        end
        render 'messages/compose'
    end

    ############################################ set_mail_defaults ####################################

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

end
