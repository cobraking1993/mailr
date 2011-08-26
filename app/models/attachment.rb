class Attachment
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :type, :charset, :encoding, :name, :description, :content, :message_id, :idx, :boundary, :format, :multipart
    attr_reader :link

    def initialize(attributes = {})

        attributes.each do |name, value|
            send("#{name}=", value)
        end

        if not @type.nil?
            params = @type.split(/;\s*/)
            @type = params[0]
            params.each do |p|
                if p =~ /=/
                    fields = p.split(/=/)
                    key = fields[0]
                    value = fields[1]
                    if Attachment.attribute_method?(key) == true
                        send("#{key}=", value)
                    end
                end
            end
        end
    end

    def multipart?
        multipart
    end

    def self.fromMultiParts(attachments,id,parts,idx=0)
        parts.each do |part|
            a = Attachment.new( :message_id => id,
                            :description => part.content_description,
                            :type => part.content_type,
                            :content => part.body.raw_source,
                            :encoding => part.content_transfer_encoding,
                            :idx => idx,
                            :multipart => part.multipart?
                            )
            if a.multipart?
				idx += 1
                fromMultiParts(attachments,id,part.parts,idx)
            else
                attachments << a
                idx += 1
            end
 #FIXME problem with enueration of attachemnts
        end
    end

    def self.fromSinglePart(attachments,id,part,idx=0)
		a = Attachment.new( :message_id => id,
							:description => part.content_description,
							:type => part.content_type,
							:encoding => part.body.encoding,
							:charset => part.body.charset,
							:content => part.body.raw_source,
							:idx => idx
							)
		attachments << a
    end


    def persisted?
        false
    end

    def name
        if @name.nil?
            case type
                when /^text\/html/
                    "index#{idx}.html"
                when /^multipart/
                    "multipart#{idx}.part"
                when /^text\/plain/
                    "file#{idx}.txt"
                else
                    "filaname.dat"
            end
        else
            @name
        end
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

    def isText?
        @type.nil? or @type =~ /^text\/plain/
    end

    def title
        @description.nil? ? name : @description
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

    def format
        @format.nil? ? '' : @format
    end

    def boundary
        @boundary.nil? ? '' : @boundary
    end

    def decode
        case @encoding
            when /quoted-printable/
                decoded = @content.gsub(/_/," ").unpack("M").first
            when /base64/
                decoded = @content.unpack("m").first
            when /uuencode/
                array = @content.split(/\n/)
                if array[0] =~ /^begin/
                    size = array.size
                    array.delete_at(size-1)
                    array.delete_at(size-2)
                    array.delete_at(0)
                end
                string = array.join
                decoded = string.unpack("u").first
            else
                decoded = @content
        end
    end

    def content_normalized

        decoded = decode

        if not @charset == 'UTF-8'
            @charset.nil? ? charset = $defaults["msg_unknown_encoding"] : charset = @charset
            charseted = Iconv.iconv("UTF-8",charset,decoded)
        else
            charseted = decoded
        end

        charseted

    end

end



