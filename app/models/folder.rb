class Folder < ActiveRecord::Base

    belongs_to :user
    validates_presence_of :name, :on => :create
    before_save :check_fill_params, :on => :create
    has_many :messages, :dependent => :destroy

    SYS_NONE = 0
    SYS_TRASH = 1
    SYS_INBOX = 2
    SYS_SENT = 3
    SYS_DRAFTS = 4

    default_scope :order => 'name asc'
    scope :shown, where(['shown = ?',true])
    scope :inbox, where(['sys = ?',SYS_INBOX])
    scope :sent, where(['sys = ?',SYS_SENT])
    scope :drafts, where(['sys = ?',SYS_DRAFTS])
    scope :trash, where(['sys = ?',SYS_TRASH])
    scope :sys, where(['sys > ?',SYS_NONE])

    def full_name
        if parent.empty?
            name
        else
            parent + delim + name
        end
    end

    def depth
        parent.split('.').size
    end

    def selected?(session_folder)
		fields = session_folder.split("#")
		fields[1].nil? ? fields.insert(0,"") : fields
		(fields[1].downcase == name.downcase) && (fields[0].downcase == parent.downcase)
    end

	def update_stats
		logger.info "MESS_BEFORE: "+messages.inspect
        unseen = messages.where(:unseen => true).count
        total = messages.count
        logger.info "MESS: "+messages.inspect
        logger.info "MESS: #{unseen} #{total}"
        update_attributes(:unseen => unseen, :total => total)
	end

	def hasFullName?(folder_name)
        full_name.downcase == folder_name.downcase
	end

	def isSystem?
        sys > SYS_NONE
    end

    def isTrash?
        sys == SYS_TRASH
    end

    def isSent?
        sys == SYS_SENT
    end

    def isInbox?
        sys == SYS_INBOX
    end

    def isDrafts?
        sys == SYS_DRAFTS
    end

    def setNone
        update_attributes(:sys => SYS_NONE)
    end

    def setTrash
        update_attributes(:sys => SYS_TRASH)
    end

    def setSent
        update_attributes(:sys => SYS_SENT)
    end

    def setInbox
        update_attributes(:sys => SYS_INBOX)
    end

    def setDrafts
        update_attributes(:sys => SYS_DRAFTS)
    end



    ############################################## private section #####################################

    private

    def check_fill_params
        self.total.nil? ? self.total = 0 : self.total
        self.unseen.nil? ? self.unseen = 0 : self.unseen
        self.parent.nil? ? self.parent = "" : self.parent
        self.haschildren.nil? ? self.haschildren = false : self.haschildren
        self.delim.nil? ? self.delim = "." : self.delim
        self.sys.nil? ? self.sys = SYS_NONE : self.sys
    end

    def self.createBulk(user,imapFolders)
        imapFolders.each do |name,data|
        data.attribs.find_index(:Haschildren).nil? ? has_children = 0 : has_children = 1
        name_fields = name.split(data.delim)

        if name_fields.count > 1
            name = name_fields.delete_at(name_fields.size - 1)
            parent = name_fields.join(data.delim)
        else
            name = name_fields[0]
            parent = ""
        end

        user.folders.create(
            :name => name,
            :parent => parent,
            :haschildren => has_children,
            :delim => data.delim,
            :total => data.messages,
            :unseen => data.unseen,
            :sys => SYS_NONE)
        end
    end

    def self.find_by_full_name(data)
        folder = data.gsub(/\./,'#')
        fields = folder.split("#")
        nam = fields.delete_at(fields.size - 1)
        fields.size.zero? == true ? par = "" : par = fields.join(".")
		where(['name = ? and parent = ?',nam,par]).first
    end

	def self.refresh(mailbox,user)
        user.folders.destroy_all
        folders=mailbox.folders
        Folder.createBulk(user,folders)
	end

end
