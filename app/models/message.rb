class Message < ActiveRecord::Base
    belongs_to :user
    belongs_to :folder

    attr_accessor :body

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

    def self.createForUser(user,folder,mess)
        create(
                :user_id => user.id,
                :folder_id => folder.id,
                :msg_id => mess.message_id,
                :uid => mess.uid,
                :from_addr => mess.from_to_db,
                :to_addr => mess.to_to_db,
                :subject => mess.subject,
                :content_type => mess.content_type,
                :date => mess.date,
                :unseen => mess.unseen,
                :size => mess.size)
    end

    def change_folder(folder)
        update_attributes(:folder_id => folder.id)
    end

end
