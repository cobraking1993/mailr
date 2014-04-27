require 'mail'

class Message < ActiveRecord::Base

    belongs_to :user
    belongs_to :folder

    #set_primary_key :uid
    self.primary_key = :uid
    attr_accessible :unseen, :to_addr, :size, :content_type, :folder_id, :subject, :date, :uid, :from_addr, :user_id, :msg_id, :body, :cc_addr, :bcc_addr
    attr_accessor :body

    def self.addr_to_db(addr)
        ret = ""
        name = addr.name
        name.nil? ? ret : ret << ApplicationController.decode_quoted(name)
        ret << "<" + addr.mailbox + "@" + addr.host
        ret
    end

    def self.getPageForUser(user,folder,page,sort_field,sort_dir)

        order = 'date desc'
        if sort_field
            if Message.attribute_method?(sort_field) == true
                order = sort_field
                sort_dir == 'desc' ? order += ' desc' : sort_dir
            end
        end

        Message.paginate :page => page , :per_page => user.prefs.msgs_per_page.to_i, :conditions=> ['user_id = ? and folder_id = ?', user.id,folder.id],:order => order
    end

    def self.createForUser(user,folder,message)

#        envelope = imap_message.attr['ENVELOPE']
#
#        envelope.from.nil? ? from = "" : from = addr_to_db(envelope.from[0])
#        envelope.to.nil? ? to = "" : to = addr_to_db(envelope.to[0])
#        envelope.subject.nil? ? subject = "" : subject = ApplicationController.decode_quoted(envelope.subject)

        mail = Mail.new(message.attr['RFC822.HEADER'])

		mail.date.nil? ? date = nil : date = mail.date.to_s
		mail.From.nil? ? from = '' : from = mail.From.charseted
		mail.To.nil? ? to = '' : to = mail.To.charseted
		mail.Subject.nil? ? subject = '' : subject = mail.Subject.charseted

		logger.custom('subject',mail.Subject)
		logger.custom('subject',subject)
		logger.custom('from',from)
		logger.custom('to',to)
		logger.custom('mail',mail.inspect)

        create(
                :user_id => user.id,
                :folder_id => folder.id,
                :msg_id => mail.message_id,
                :uid => message.attr['UID'].to_i,
                :from_addr => from,
                :to_addr => to[0..254],
                :subject => subject,
                :content_type => mail.content_type,
                :date => date,
                :unseen => !(message.attr['FLAGS'].member? :Seen),
                :size => message.attr['RFC822.SIZE']
            )
        end

    def change_folder(folder)
        update_attributes(:folder_id => folder.id)
    end

end
