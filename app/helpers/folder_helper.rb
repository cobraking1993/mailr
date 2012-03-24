module FolderHelper

    def folder_link(options={})
			
				folder = options[:folder]
				active = ""
				if options[:active]
					active = "icon-white"
				end

        folder.parent.empty? ? name = folder.name : name = folder.parent.gsub(/\./,'#') + "#" + folder.name

        if folder.isInbox?
            name_shown = "<i class=\"icon-inbox #{active}\"></i>" + t(:inbox_name,:scope => :folder)
        elsif folder.isSent?
            name_shown = "<i class=\"icon-plane #{active}\"></i>" + t(:sent_name,:scope => :folder)
        elsif folder.isDrafts?
            name_shown = "<i class=\"icon-book #{active}\"></i>" + t(:drafts_name,:scope => :folder)
        elsif folder.isTrash?
            name_shown = "<i class=\"icon-trash #{active}\"></i>" +t(:trash_name,:scope => :folder)
        else
            name_shown = "<i class=\"icon-none\"></i>" + folder.name.capitalize
        end
        
        if folder.isTrash?
            if not folder.total.zero?
                name_shown += " <button class=\"btn btn-mini btn-danger\" onclick=\"window.location='#{folders_emptybin_path}'\" href=\"#\">#{t(:emptybin,:scope=>:folder)}</button>"
                #name_shown += raw link_to(t(:emptybin,:scope=>:folder),folders_emptybin_path)
                #name_shown += ')'
            end
        else
            if !folder.unseen.zero?
                name_shown += ' (' + folder.unseen.to_s + ')'
            end
        end
        
        link_to name_shown.html_safe, folders_select_path(:id => name)
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
