class Attachment
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :type, :charset, :encoding, :name, :description, :content, :message_id, :idx
    attr_reader :link

    def initialize(attributes = {})
        attributes.each do |name, value|
            send("#{name}=", value)
        end

        if @type =~ /name=(\S+)/
            @name = $1
            @type =~ /^(\S+);/
           @type = $1
        else
            @name = "no_name.dat"
        end
    end

    def persisted?
        false
    end

    def to_s
        s = "Attachment:\n"
        instance_variables.sort.each do |name|
            if name == "@content"
                s += "\t#{name}: size #{instance_variable_get(name).size}\n"
            else
                s += "\t#{name}: #{instance_variable_get(name)}\n"
            end
        end
        s
    end

    def title
        @description.nil? ? @name : @description
    end

    def type
        @type.nil? ? '' : @type
    end

    def charset
        @charset.nil? ? '' : @charset
    end

    def encoding
        @encoding.nil? ? '' : @encoding
    end

#    def to_html
#        html = "<span class=\"attachment\">"
#        html << "<span class=\"title\">"
#        html << "<a href=\"/messages/attachment/#{@message_id}/#{@idx}\">#{@description.nil? ? @name : @description}</a>"
#        html << "</span> #{@type}"
#        @charset.nil? ? html : html << " #{@charset}"
#        @encoding.nil? ? html : html << " #{@encoding}"
#        case @type
#            when /^message\/delivery-status/
#                html << "<pre>"
#                html << @content
#                html << "</pre>"
#            #when /^message\/rfc822/
#            #    html << "<pre>"
#            #    html << @content
#            #    html << "</pre>"
#        end
#        html << "</span>"
#    end

#    def to_table
#        html = ""
##        @type.nil? ? html << "<td></td>" : html << "<td>#{@type}</td>"
#        @charset.nil? ? html << "<td></td>" : html << "<td>#{@charset}</td>"
#        @encoding.nil? ? html << "<td></td>" : html << "<td>#{@encoding}</td>"

#        html
#    end

    def content_decoded
    # TODO attachments decoding
        @content
    end

end
