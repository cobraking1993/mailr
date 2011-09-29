require 'imap_session'
require 'imap_mailbox'
require 'imap_message'
require 'mail'
require 'mail_plugin_extension'
require 'net/smtp'

class MessagesOpsController < ApplicationController

    include ImapMailboxModule
	include ImapSessionModule
	include ImapMessageModule
	include MessagesHelper

    before_filter :check_current_user ,:selected_folder,:get_current_folders
    before_filter :open_imap_session, :select_imap_folder
    before_filter :prepare_compose_buttons
    before_filter :get_system_folders, :only => [:composed,:single,:multi]
    before_filter :prepare_composed , :only => [:composed]
    before_filter :create_message_with_params, :only=> [:composed,:single,:multi]
    after_filter :close_imap_session
    theme :theme_resolver


    ############################################### single #####################################

    def single
        if params[:reply]
            reply
            return
        elsif params[:trash]
            trash
        elsif params[:move]
            move
        elsif params[:copy]
            copy
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
            flash[:error] = "#{t(:imap_error,:scope=>:internal)} (#{e.to_s})"
        end
        redirect_to :controller => 'messages', :action => 'index'
    end

    ############################################### ################################################


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

    def upload
        begin
            raise MailrException.new :cause=>:no_tmp_dir,:scope=>:common if not File.exists?($defaults["msg_upload_dir"])
            raise MailrException.new :cause=>:no_file_chosen,:scope=>:common if not params[:upload]
            @operation = :upload
			name = params[:file][:data].original_filename
			upload_dir = $defaults["msg_upload_dir"]
			path = File.join(upload_dir, @current_user.username + "_" + name)
			File.open(path, "wb") { |f| f.write(params[:file][:data].read) }
        rescue MailrException => e
            flash[:error] = t(e.message[:cause],:scope => e.message[:scope])
        rescue Exception => e
            flash[:error] = t(:general_error,:scope=>:internal) + " (" + e.class.name + " " + e.to_s + ")"
		end
		create_message_with_params
		render 'messages/compose'
    end

#    Files uploaded from Internet Explorer:
#
#Internet Explorer includes the entire path of a file in the filename sent, so the original_filename routine will return something like:
#
#C:\Documents and Files\user_name\Pictures\My File.jpg
#
#instead of just:
#
#My File.jpg
#
#This is easily handled by File.basename, which strips out everything before the filename.
#
#def sanitize_filename(file_name)
#  # get only the filename, not the whole path (from IE)
#  just_filename = File.basename(file_name)
#  # replace all none alphanumeric, underscore or perioids
#  # with underscore
#  just_filename.sub(/[^\w\.\-]/,'_')
#end
#
#Deleting an existing File:
#
#If you want to delete any existing file then its simple and need to write following code:
#
#  def cleanup
#    File.delete("#{RAILS_ROOT}/dirname/#{@filename}")
#            if File.exist?("#{RAILS_ROOT}/dirname/#{@filename}")
#  end

    def composed
        if params[:delete_marked] and params[:files]
            params[:files].each do |filename|
                path = File.join(Rails.root,$defaults["msg_upload_dir"],@current_user.username + "_" +filename)
                File.delete(path) if File.exist?(path)
            end
            create_message_with_params
            @operation = :new
            render 'messages/compose'
            return
        elsif params[:upload]
            upload
        elsif params[:save]
            save
        elsif params[:sendout]
            sendout
        else
            redirect_to :controller => 'messages', :action => 'index'
        end
    end

	def sendout
        begin
            smtp_server = @current_user.servers.primary_for_smtp
            raise MailrException.new :cause=>:not_configured_smtp,:scope => :compose if smtp_server.nil?
            raise MailrException.new :cause=>:has_no_domain,:scope=>:user if @current_user.has_domain?.nil?
            raise MailrException.new :cause=>:not_configured_sent,:scope=>:compose if @sent_folder.nil?
            send_mail_message(  smtp_server,
                                @current_user.has_domain?,
                                @current_user.login,
                                @current_user.get_cached_password(session),
                                @mail.to_s,
                                @current_user.email,
                                params[:message][:to_addr]
                                )
			upload_dir = $defaults["msg_upload_dir"]
			@attachments.each do |file|
                path = File.join(upload_dir, @current_user.username + "_" + file[:name])
                File.delete(path) if File.exist?(path)
            end
        rescue MailrException => e
            flash[:error] = t(e.message[:cause],:scope => e.message[:scope])
        rescue Exception => e
            flash[:error] = t(:general_error,:scope=>:internal) + " (" + e.class.name + " " + e.to_s + ")"
        else
            flash[:notice] = t(:was_sent,:scope => :compose)
            redirect_to :controller => 'messages', :action => 'index'
            return
        end
        @operation = :new
        render 'messages/compose'
    end

    def save
        begin
            raise MailrException.new :cause=>:not_configured_drafts,:scope=>:folder if @drafts_folder.nil?
            @mailbox.append(@drafts_folder.full_name,@mail.to_s,[:Seen])
            if params[:olduid].present?
                @mailbox.move_message(params[:olduid],@trash_folder.full_name)
                @mailbox.expunge
            end
        rescue MailrException => e
            flash[:error] = t(e.message[:cause],:scope => e.message[:scope])
        rescue Exception => e
            flash[:error] = t(:general_error,:scope=>:internal) + " (" + e.class.name + " " + e.to_s + ")"
        else
            @attachments.each do |filename|
                path = File.join(Rails.root,filename)
                File.delete(path) if File.exist?(path)
            end
            flash[:notice] = t(:was_saved,:scope => :compose)
        end
        redirect_to :controller => 'messages', :action => 'index'
	end

    #FIXME edit does not support attachments
    def edit
        old_message = @current_user.messages.find(params[:id])
        @message = Message.new
        @message.to_addr = old_message.to_addr
        @message.subject = old_message.subject

        imap_message = @mailbox.fetch_body(old_message.uid)
        mail = Mail.new(imap_message)
        if mail.multipart?
            @message.body = mail.text_part.nil? ? "" : mail.text_part.decoded_and_charseted.gsub(/<\/?[^>]*>/, "")
        else
            @message.body = mail.decoded_and_charseted.gsub(/<\/?[^>]*>/, "")
        end
        @attachments = []
        @operation = :edit
        @olduid = old_message.uid
        render 'messages/compose'
	end

    def reply
        old_message = @current_user.messages.find(params[:uids].first)
        @message = Message.new
        @message.to_addr = old_message.from_addr
        @message.subject = old_message.subject

        imap_message = @mailbox.fetch_body(old_message.uid)
        mail = Mail.new(imap_message)
        if mail.multipart?
            @message.body = mail.text_part.nil? ? "" : mail.text_part.decoded_and_charseted.gsub(/<\/?[^>]*>/, "")
        else
            @message.body = mail.decoded_and_charseted.gsub(/<\/?[^>]*>/, "")
        end
        @attachments = []
		@operation = :reply
        render 'messages/compose'
    end
    ###################################### protected section #######################################

    protected

    def send_mail_message(smtp_server,domain,username,password,msgstr,from,to)
        if smtp_server.auth.nil?
            smtp = Net::SMTP.start(smtp_server.name, smtp_server.port, domain)
        else
            smtp = Net::SMTP.start(smtp_server.name, smtp_server.port, domain, username, password, smtp_server.auth)
        end
        smtp.send_message msgstr, from, to
        smtp.finish
    end

    def prepare_composed
        @mail = Mail.new
        @mail.subject = params[:message][:subject]
        @mail.from = @current_user.full_id
        #TODO check if email address is valid if not get address from contacts
        @mail.to = params[:message][:to_addr]
        @mail.body = params[:message][:body]
        @attachments = Dir.glob(File.join($defaults["msg_upload_dir"],@current_user.username + "*"))
        @attachments.each do |a|
            @mail.add_file :filename => File.basename(a.gsub(/#{@current_user.username}_/,"")), :content => File.read(a)
        end
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
            user_name = user.login
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
