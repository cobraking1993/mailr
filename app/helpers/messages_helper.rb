module MessagesHelper

    def size_formatter(size)
        if size <= 2**10
            "#{size} #{t(:bytes,:scope=>:common)}"
        elsif size <= 2**20
            sprintf("%.1f #{t(:kbytes,:scope=>:common)}",size.to_f/2**10)
        else
            sprintf("%.1f #{t(:mbytes,:scope=>:common)}",size.to_f/2**20)
        end
    end

    def date_formatter(date)
        date.nil? ? t(:no_date,:scope=>:message) : date.strftime("%Y-%m-%d %H:%M")
    end

    def address_formatter(addr,op)
        s = ""
        return t(:no_address,:scope=>:message) if addr.empty?
        length = $defaults["msg_address_length"].to_i

            case op
                when :index
										logger.custom('addr',addr)
                    fs = addr.gsub(/\"/,"").split(/</)
                    fs[0].size.zero? ? s = fs[1] : s = fs[0]
                    s.length >= length ? s = s[0,length]+"..." : s
                    return h(s)
                when :show
                    #addr = addr[0].charseted.gsub(/\"/,"")
                    return h(addr.gsub(/\"/,""))
                when :raw
                    #fs = addr.gsub(/\"/,"").split(/</)
                    #fs[0].size.zero? ? s = fs[1] : s << fs[0] + " <" + fs[1] + ">"
                    s = h(addr)
                    return s
								when :reply
										return addr
								end
    end

    def body_formatter(body,op)
		case op
			when :reply
				s = "\n\n\n"
				body.split(/\n/).each do |line|
					s += '>' + line.strip	+ "\n"
				end
				s
			when :edit
				return body
			when :plain
				safe_body = h(body)
				s = ""
				safe_body.split(/\n/).each do |line|
					s += line.gsub(/^\s+/,"") + "<br/>"
				end
				s.html_safe
			end
    end

    def subject_formatter(message,op)
		case op
			when :index
				if message.subject.nil? or message.subject.size.zero?
					s = t(:no_subject,:scope=>:message)
				else
					length = $defaults["msg_subject_length"].to_i
					message.subject.length >= length ? s = message.subject[0,length]+"..." : s = message.subject
				end
				link_to s,{:controller => 'messages', :action => 'show', :id => message.uid} , :title => message.subject
			when :show
				if message.subject.nil? or message.subject.size.zero?
					t(:no_subject,:scope=>:message)
				else
					message.subject
				end
			when :reply
				if message.nil? or message.size.zero?
					t(:reply_string,:scope=>:show)
				else
					t(:reply_string,:scope=>:show) + " " + message
				end
		end
    end

    def attachment_formatter(message)
        message.content_type =~ /^text\/plain/ ? "" : "<i class=\"icon-file\"></i>"
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
				if @current_folder == @drafts_folder
					html << "<th>&nbsp;</th>"
				end
        html
    end

    #def content_text_plain_for_render(text)
        #html = "<pre class=\"clearfix\">"
        ##html << text.gsub!(/\r\n/,"\n")
        #html << h(text)
        #html << "</pre>"
        #html
    #end
    
    def humanize_attr(object,attr)
			model_name = eval(object.class.model_name)
			return model_name.human_attribute_name(attr)
    end

end

