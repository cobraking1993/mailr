class Contact < ActiveRecord::Base

    validates_length_of :name, :within => 3..20
    validates_length_of :email, :within => 5..50
    validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    validates_length_of :info, :maximum => 100
    validate :check_unique_name, :on => :create
    default_scope :order => 'name ASC'

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

    def check_unique_name
        if !Contact.where('upper(name) = ? and user_id = ?',name.upcase,user_id).size.zero?
            errors.add(:name, :not_unique)
        end
    end

    def export
        fields = []
        fields << name || ""
        fields << email || ""
        fields << info || ""
        fields.join(';')
    end

    def self.import(user,line)
        fields = line.split(/;/)
        contact = user.contacts.build(  :name => fields[0].strip,
                                        :email => fields[1].strip,
                                        :info => fields[2].strip)
        contact.save!
    end
end
