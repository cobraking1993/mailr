module MessagesHelper

    def size_formatter(size)
        if size <= 2**10
            "#{size} #{t(:bytes)}"
        elsif size <= 2**20
            sprintf("%.1f #{t(:kbytes)}",size.to_f/2**10)
        else
            sprintf("%.1f #{t(:mbytes)}",size.to_f/2**20)
        end
    end

    def date_formatter(date)
        date.nil? ? t(:no_data) : date.strftime("%Y-%m-%d %H:%M")
    end

    def address_formatter(addr,mode)
        s = ""
        length = $defaults["msg_address_length"].to_i
        fs = addr.split(/</)

        if not fs.size.zero?
            case mode
                when :index
                    fs[0].size.zero? ? s = fs[1] : s = fs[0]
                    s.length >= length ? s = s[0,length]+"..." : s
                    return h(s)
                when :message
                    fs[0].size.zero? ? s = "<" + fs[1] + ">" : s << fs[0] + " <" + fs[1] + ">"
                    return h(s)
                when :raw
                    fs[0].size.zero? ? s = fs[1] : s << fs[0] + " <" + fs[1] + ">"
                    return s
            end
        end
    end

    def show_addr_formatter(addrs)
        return h(force_charset(addrs[0].decoded))
    end

    def show_subject_formatter(subject)
        if subject.to_s.nil?
            t(:no_subject,:scope=>:message)
        else
            return h(force_charset(subject.decoded))
        end
    end


    def subject_formatter(message)
        if message.subject.size.zero?
            s = t(:no_subject,:scope=>:message)
        else
            length = $defaults["msg_subject_length"].to_i
            message.subject.length >= length ? s = message.subject[0,length]+"..." : s = message.subject
        end
        link_to s,{:controller => 'messages', :action => 'show', :id => message.uid} , :title => message.subject
    end

    def attachment_formatter(message)
        message.content_type == 'text' ? "" : "A"
    end

    def headers_links
        #if @current_folder.hasFullName?(@folder_sent_name) || @current_folder.hasFullName?(@folder_drafts_name)
        if @current_folder == @sent_folder || @current_folder == @drafts_folder
            fields = $defaults["msgs_sent_view_fields"]
        else
            fields = $defaults["msgs_inbox_view_fields"]
        end

        html = ""
        fields.each do |f|
            html << "<th>"
            if params[:sort_field] == f
                params[:sort_dir].nil? ? dir = 'desc' : dir = nil
            end

            html << link_to(Message.human_attribute_name(f), {:controller => 'messages',:action => 'index',:sort_field => f,:sort_dir => dir}, {:class=>"header"})
            html << "</th>"
        end
        html
    end

    def content_text_plain_for_render(text)
        html = "<pre>"
        #html << text.gsub!(/\r\n/,"\n")
        html << h(text)
        html << "</pre>"
        html
    end

end

