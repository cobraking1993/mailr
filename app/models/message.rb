require 'iconv'

class Message < ActiveRecord::Base

    belongs_to :user
    belongs_to :folder

    set_primary_key :uid
    attr_accessible :unseen, :to_addr, :size, :content_type, :folder_id, :subject, :date, :uid, :from_addr, :user_id, :msg_id

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

    def self.createForUser(user,folder,imap_message)

        envelope = imap_message.attr['ENVELOPE']

        from = addr_to_db(envelope.from[0])
        to = addr_to_db(envelope.to[0])

        envelope.subject.nil? ? subject = "" : subject = ApplicationController.decode_quoted(envelope.subject)

        create(
                :user_id => user.id,
                :folder_id => folder.id,
                :msg_id => envelope.message_id,
                :uid => imap_message.attr['UID'].to_i,
                :from_addr => from,
                :to_addr => to,
                :subject => subject,
                :content_type => imap_message.attr['BODYSTRUCTURE'].media_type.downcase,
                :date => envelope.date,
                :unseen => !(imap_message.attr['FLAGS'].member? :Seen),
                :size => imap_message.attr['RFC822.SIZE']
            )
        end

    def change_folder(folder)
        update_attributes(:folder_id => folder.id)
    end


end
