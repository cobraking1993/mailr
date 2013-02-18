module NotesHelper

    def notes_table_header
        html = ""
        $defaults["notes_table_fields"].each do |f|
            html << "<th>"
            if params[:sort_field] == f
                params[:sort_dir].nil? ? dir = 'desc' : dir = nil
            end

            html << link_to(Note.human_attribute_name(f), { :controller => 'notes',
                                                            :action => 'index',
                                                            :sort_field => f,
                                                            :sort_dir => dir
                                                          },
                                                          { :class=>"header"
                                                          }
                            )
            html << "</th>"
        end
        html
    end

end
