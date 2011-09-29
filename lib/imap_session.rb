require 'net/imap'
require 'imap_mailbox'

module ImapSessionModule

def open_imap_session
	begin
		@mailbox ||= ImapMailboxModule::IMAPMailbox.new(logger,$defaults["imap_debug"])
		@mailbox.connect(@current_user.servers.primary_for_imap,@current_user.login, @current_user.get_cached_password(session))
	rescue Exception => ex
		redirect_to :controller => 'internal', :action => 'loginfailure'
	end
end

def close_imap_session
	return if @mailbox.nil? or not(@mailbox.connected)
	@mailbox.disconnect
	@mailbox = nil
end

def select_imap_folder
    @mailbox.set_folder(@current_folder.full_name) if not @current_folder.nil?
end

end
