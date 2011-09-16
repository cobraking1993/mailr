class Contact < ActiveRecord::Base

    validates_length_of :nick, :within => 5..15
    validates_length_of :first_name,:last_name, :within => 3..20
    validates_length_of :email, :within => 5..50
    validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    validates_length_of :info, :maximum => 100
    validate :check_unique_nick, :on => :create
    default_scope :order => 'nick ASC'

    belongs_to :user

    def self.getPageForUser(user,page,sort_field,sort_dir)

        if sort_field
            if Contact.attribute_method?(sort_field) == true
                order = sort_field
                sort_dir == 'desc' ? order += ' desc' : sort_dir
            end
        end

        Contact.paginate :page => page , :per_page => $defaults["contacts_per_page"], :conditions=> ['user_id = ?', user.id],:order => order
    end

    def full_name
        first_name + ' ' + last_name
    end

    def check_unique_nick
        if !Contact.where('upper(nick) = ? and user_id = ?',nick.upcase,user_id).size.zero?
            errors.add(:nick, :not_unique)
        end
    end

    def export
        fields = []
        fields << nick.presence || ""
        fields << first_name || ""
        fields << last_name || ""
        fields << email || ""
        fields << info || ""
        fields.join(';')
    end

    def self.import(user,line)
        fields = line.split(/;/)
        contact = user.contacts.build(  :nick => fields[0].strip,
                                        :first_name => fields[1].strip,
                                        :last_name => fields[2].strip,
                                        :email => fields[3].strip,
                                        :info => fields[4].strip)
        contact.save!
    end
end
