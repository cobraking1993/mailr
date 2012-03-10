require 'net/imap'

module ImapFolderModule

class IMAPFolder

    attr_reader :utf7_name
    attr_reader :delim
    attr_reader :attribs
    attr_reader :name
    attr_accessor :messages
    attr_accessor :unseen

    def initialize(utf7_name,delim,attribs)
        @utf7_name = utf7_name
        @name = Net::IMAP.decode_utf7 utf7_name
        @delim = delim
        @attribs = attribs
    end

end

end
