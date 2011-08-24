module FolderHelper

    def folder_link(folder)

        folder.parent.empty? ? name = folder.name : name = folder.parent.gsub(/\./,'#') + "#" + folder.name
        s = link_to folder.name.capitalize, folders_select_path(:id => name)

        if folder.full_name.downcase == $defaults["mailbox_trash"].downcase
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
        folder.nil? ? t(:no_selected,:scope=>:folder) : folder.name.capitalize
    end

    def select_for_folders(name,id,object,label,blank)
        html = ""
        html << "<div class=\"group\">"
        html << "<label class=\"label\">#{label}</label>"
        html << simple_select_for_folders(name,id,object,blank)
        html << "</div>"
    end

    def simple_select_for_folders(name,id,object,blank)
        html = ""
        html << select(name, id, object.all.collect {|p| [ p.parent.empty? ? p.name : p.parent+p.delim+p.name, p.id ] }, { :include_blank => (blank == true ? true : false)})
        html
    end

end
