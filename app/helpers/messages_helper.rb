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

#    def address_formatter(addr)
#        ImapMessageModule::IMAPAddress.parse(addr).friendly
#    end

    def address_formatter(addr,mode)
        s = ""
        length = $defaults["msg_address_length"].to_i
        fs = addr.split(/</)

        if mode == :index
            fs[0].size.zero? ? s = fs[1] : s = fs[0]
            s.length >= length ? s = s[0,length]+"..." : s
        else
            fs[0].size.zero? ? s = "<" + fs[1] + ">" : s << fs[0] + " <" + fs[1] + ">"
        end

        return h(s)

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

        if @current_folder.hasFullName?($defaults["mailbox_sent"])
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
        html << h(text)
        html << "</pre>"
        html
    end

end

