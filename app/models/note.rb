class Note < ActiveRecord::Base
  attr_accessible :body, :user_id, :title
  belongs_to :user
  validates_presence_of :body
  validates_length_of :body, :maximum => 1000
  validates_presence_of :title
  validates_length_of :title, :minimum => 3, :maximum => 50

  def self.getPageForUser(user,page,sort_field,sort_dir)
    if sort_field
        if Note.attribute_method?(sort_field) == true
            order = sort_field
            sort_dir == 'desc' ? order += ' desc' : sort_dir
        end
    end
      Note.paginate :page => page, :per_page => $defaults["notes_per_page"], :conditions=> ['user_id = ?', user.id], :order => order
  end

  def export
      fields = []
      fields << "\"#{title}\"" || ""
      fields << "\"#{body}\"" || ""
      fields.join(';')
  end

  def self.import(user,line)
      fields = line.split(/;/)
      note = user.notes.build(  :title => fields[0].strip,
                                :body => fields[1].strip
                              )
      note.save!
  end

end
