module FolderHelper

    def folder_link(folder)

        folder.parent.empty? ? name = folder.name : name = folder.parent.gsub(/\./,'#') + "#" + folder.name

        if folder.isInbox?
            name_shown = t(:inbox_name,:scope => :folder)
        elsif folder.isSent?
            name_shown = t(:sent_name,:scope => :folder)
        elsif folder.isDrafts?
            name_shown = t(:drafts_name,:scope => :folder)
        elsif folder.isTrash?
            name_shown = t(:trash_name,:scope => :folder)
        else
            name_shown = folder.name.capitalize
        end
        s = link_to name_shown, folders_select_path(:id => name)

        if folder.isTrash?
            if not folder.total.zero?
                s <<' ('
                s << link_to(t(:emptybin,:scope=>:folder),folders_emptybin_path)
                s << ')'
            end
        else
            if !folder.unseen.zero?
                s += ' (' + folder.unseen.to_s + ')'
            end
        end
        s
    end

    def pretty_folder_name(folder)
        if folder.nil?
            t(:no_selected,:scope=>:folder)
        else
            if folder.isInbox?
                t(:inbox_name,:scope => :folder)
            elsif folder.isSent?
                t(:sent_name,:scope => :folder)
            elsif folder.isDrafts?
                t(:drafts_name,:scope => :folder)
            elsif folder.isTrash?
                t(:trash_name,:scope => :folder)
            else
                folder.name.capitalize
            end
        end
    end

    def select_for_folders(name,id,collection,label,choice,blank)
        html = ""
        html << "<div class=\"param_group\">"
        html << "<label class=\"label\">#{label}</label>"
        html << simple_select_for_folders(name,id,collection,choice,blank)
        html << "</div>"
    end

    def simple_select_for_folders(name,id,collection,choice,blank)
        html = ""
        html << select(name , id, options_from_collection_for_select(collection, 'id', 'full_name', choice),{ :include_blank => (blank == true ? true : false)})
        html
    end

end
