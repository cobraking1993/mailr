module ContactsHelper

    def contacts_table_header
        html = ""
        $defaults["contacts_table_fields"].each do |f|
            html << "<th>"
            if params[:sort_field] == f
                params[:sort_dir].nil? ? dir = 'desc' : dir = nil
            end

            html << link_to(Contact.human_attribute_name(f), {:controller => 'contacts',:action => 'index',:sort_field => f,:sort_dir => dir}, {:class=>"header"})
            html << "</th>"
        end
        html
    end

end
