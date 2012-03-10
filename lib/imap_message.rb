require 'net/imap'

module ImapMessageModule

class IMAPAddress

    attr_accessor :name,:mailbox,:host

    def initialize()
        name = ""
        mailbox = ""
        host = ""
    end

    def self.from_address(addr)
        a = IMAPAddress.new()
        a.name = addr.name || ""
        a.mailbox = addr.mailbox || ""
        a.host = addr.host || ""
        a
    end

    def to_db
        name + "#" + mailbox + "#" + host
    end

    def self.parse(addr)
        a = IMAPAddress.new()
        f = addr.split("#")
        a.name = f[0]
        a.mailbox = f[1]
        a.host = f[2]
        a
    end

    def friendly
        if name.empty?
            mailbox + host
        else
            name
        end
    end

end

class IMAPMessage

    @@fetch_attr = ['RFC822.HEADER', 'FLAGS', 'UID', 'RFC822.SIZE']
    #@@fetch_attr = ['RFC822','FLAGS', 'UID', 'RFC822.SIZE']

#    attr_accessor :envelope,:uid,:content_type,:size,:unseen,:from,:message_id,:to,:from,:subject,:date
#
#    def initialize
#    end
#
#    def self.fromImap(message)
#        m = IMAPMessage.new
#        envelope = message.attr['ENVELOPE']
#        m.envelope = envelope
#        m.message_id = envelope.message_id
#        m.date = envelope.date
#        m.subject = envelope.subject
#        m.uid = message.attr['UID']
#        #content_type = m.attr['BODYSTRUCTURE'].multipart? ? 'multipart' : 'text'
#        m.content_type = message.attr['BODYSTRUCTURE'].media_type.downcase
#        m.size = message.attr['RFC822.SIZE']
#        m.unseen = !(message.attr['FLAGS'].member? :Seen)
#        m.from = IMAPAddress.from_address(envelope.from[0])
#        m.to = IMAPAddress.from_address(envelope.to[0])
#        m
#    end
#
    def self.fetch_attr
        @@fetch_attr
    end
#
#    def from_to_db
#        from.to_db
#    end
#
#    def to_to_db
#        to.to_db
#    end

end




end

