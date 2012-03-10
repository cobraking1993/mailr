require 'net/imap'
require 'imap_folder'

module ImapMailboxModule

class IMAPError < RuntimeError
end

class IMAPMailbox

	attr_reader :connected
	attr_accessor :sfolder
	attr_accessor :logger

	def initialize(logger,debug)
		@sfolder = ''
		@folders = {}
		@connected = false
		@logger = logger
		Net::IMAP.debug = true
	end

	def connect(server,username,password)

        server_name = server.name
        server_port = server.port
        server_use_ssl = server.use_ssl

		unless @connected
			begin
				@imap = Net::IMAP.new(server_name, server_port, server_use_ssl)
			rescue Net::IMAP::ByeResponseError => bye
				begin
					System.sleep($defaults["imap_bye_timeout_retry_seconds"])
					@imap = Net::IMAP.new(server_name, server_port, server_use_ssl)
				rescue Exception => ex
					raise IMAPError, ex.inspect
				end
			rescue Exception => ex
				raise IMAPError, ex.inspect
			end
			@username = username
			begin
				@imap.login(username, password)
				@connected = true
			rescue Exception => ex
				raise IMAPError, ex.inspect
			end
		end
	end

	def disconnect
		 if @connected
			@imap.logout
			@imap.disconnect
			@imap = nil
			@connected = false
		 end
	end

    def folders
        @folders = {}
        folders = @imap.list('', '*')
        if folders
            folders.each do |f|
                folder = ImapFolderModule::IMAPFolder.new(f.name,f.delim,f.attr)
                status = @imap.status(folder.name, ["MESSAGES", "UNSEEN"])
                folder.messages = status["MESSAGES"]
                folder.unseen = status["UNSEEN"]
                @folders[folder.name] = folder
            end
        end
        @folders
    end

    def create_folder(name)
        begin
            @imap.create(Net::IMAP.encode_utf7(name))
        rescue Exception => e
            raise e
        end
    end

    def fetch_uids
        begin
            uids = []
            imap_uids = @imap.fetch(1..-1, "UID")
            imap_uids.each do |u|
                uids << u.attr['UID']
            end
            return uids
        rescue Exception => e
            raise e
        end
    end

    def delete_folder(name)
        begin
            @imap.delete(Net::IMAP.decode_utf7(name))
        rescue Exception => e
            raise e
        end
    end

    def fetch(range,attribs)
        begin
            @imap.fetch(range,attribs)
        rescue Exception => e
            raise e
        end
    end

    def uid_fetch(range,attribs)
        begin
            @imap.uid_fetch(range,attribs)
        rescue Exception => e
            raise e
        end
    end

    def set_folder(folder_name)
        begin
            if folder_name != @sfolder
                @imap.select(folder_name)
                @sfolder = folder_name
            end
        rescue Exception => e
            raise e
        end
    end

    def status
        begin
            @imap.status(@sfolder, ["MESSAGES", "RECENT", "UNSEEN"])
        rescue Exception => e
            raise e
        end
    end

    def fetch_body(uid)
        begin
            uid_fetch(uid,"BODY[]").first.attr["BODY[]"]
        rescue Exception => e
            raise e
        end
    end

    def delete_message(uid)
        begin
            @imap.uid_store(uid.to_i, "+FLAGS", :Deleted)
        rescue Exception => e
            raise e
        end
    end

    def expunge
        begin
            @imap.expunge
        rescue Exception => e
            raise e
        end
    end

    def set_read(uid)
        begin
            @imap.uid_store(uid.to_i, "+FLAGS", :Seen)
        rescue Exception => e
            raise e
        end
    end

    def set_unread(uid)
        begin
            @imap.uid_store(uid.to_i, "-FLAGS", :Seen)
        rescue Exception => e
            raise e
        end
    end

    def copy_message(uid,dest_folder)
        begin
            @imap.uid_copy(uid.to_i, dest_folder)
        rescue Exception => e
            raise e
        end
    end

    def move_message(uid,dest_folder)
        begin
            copy_message(uid,dest_folder)
            delete_message(uid)
        rescue Exception => e
            raise e
        end
    end

    def append(folder,message,flags)
        begin
            @imap.append(folder,message,flags)
        rescue Exception => e
            raise e
        end
    end

end

end
