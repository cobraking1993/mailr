class Server < ActiveRecord::Base

	validates_presence_of :name
	belongs_to :user
	#before_save :fill_params

	def self.primary_for_imap
		where(:for_imap=>true).first
	end

	def self.primary_for_smtp
        where(:for_smtp=>true).first
    end

    def self.create_default(user)
        create_server(user,"localhost")
    end
    
    def self.create_server(user,server)
        create( :user_id=>user.id,
                :name=>server,
                :port=>$defaults['imap_port'],
                :use_ssl=>false,
                :use_tls=>false,
                :for_smtp=>false,
                :for_imap=>true
                )
        create( :user_id=>user.id,
                :name=>server,
                :port=>$defaults['smtp_port'],
                :use_ssl=>false,
                :use_tls=>false,
                :for_smtp=>true,
                :for_imap=>false
                )
    end

#	private

#	def fill_params
#        port.nil? ? port = $defaults['imap_port'] : port
#        $defaults['imap_use_ssl'] == true ? self.use_ssl = 1 : self.use_ssl = 0
#	end

end
