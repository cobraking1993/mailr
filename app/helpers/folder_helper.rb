module FolderHelper

  def pretty_folder_name(folder)
    if folder.nil?
      t(:no_selected, :scope=>:folder)
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

  # Folder link consists of three elements: icon, name, info. Info can be a label showing unreaded messages or link to empty trashbin.
  # 
  def folder_link(options={})
		
		folder = options[:folder]
    active = options[:active]
    sys_icons = $defaults["system_folders_icons"]
    other_icon = $defaults["other_folders_icon"]

    folder_link = folder.parent.empty? ? folder.name : folder.parent.gsub(/\./,'#') + "#" + folder.name
    icon = folder.sys > 0 ? sys_icons[folder.sys - 1] : other_icon
    icon_tag = content_tag(:i, "", :class => (c = "icon-#{icon}"; c += " icon-white" if active and folder.sys; c))
    info = ""
    
    name_shown = pretty_folder_name(folder)

    if folder.isTrash?
      info = content_tag(:button,
                           t(:emptybin, :scope=>:folder),
                           :type => "submit",
                           :class => "btn btn-mini btn-danger folder_action") unless folder.total.zero?
      info = content_tag(:form, info, :action => folders_emptybin_path)
    end

    unless (folder.isTrash? or folder.unseen.zero?)
      info = content_tag(:span, folder.unseen.to_s, :class => "label label-important folder_info")
    end
    
    content_tag(:a,icon_tag + name_shown, :href => folders_select_path(:id => folder_link)) + info
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
