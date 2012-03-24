class Link < ActiveRecord::Base
	validates_length_of :name, :within => 5..30
	validates_length_of :url, :within => 5..150
	validates_length_of :info, :maximum => 50
	belongs_to :user
	default_scope :order => 'name asc'

	def self.getPageForUser(user,page,sort_field,sort_dir)

		if sort_field
            if Link.attribute_method?(sort_field) == true
                order = sort_field
                sort_dir == 'desc' ? order += ' desc' : sort_dir
            end
        end

        Link.paginate :page => page , :per_page => $defaults["links_per_page"], :conditions=> ['user_id = ?', user.id],:order => order
    end
end
