module PrefsHelper
	def servers_table_header
        html = ""
        $defaults["servers_table_fields"].each do |f|
            html << "<th>"
            if params[:sort_field] == f
                params[:sort_dir].nil? ? dir = 'desc' : dir = nil
            end

            html << link_to(Server.human_attribute_name(f), {:controller => 'prefs',:action => 'servers',:sort_field => f,:sort_dir => dir}, {:class=>"header"})
            html << "</th>"
        end
        html
    end

end
