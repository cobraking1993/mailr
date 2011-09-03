
class Attachment
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :type, :charset, :encoding, :name, :description, :content, :message_id, :idx, :boundary, :format, :multipart,:size,:cid
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
                    fields.delete_at(0)
                    value = fields.join("=")
                    # FIXME maybe do decoding only for name and filename key
                    if Attachment.attribute_method?(key) == true
                        send("#{key}=", ApplicationController.decode_quoted(value))
                    end
                end
            end
        end
    end

    def multipart?
        multipart
    end

    def self.fromMultiParts(attachments,id,parts)
        parts.each do |part|
			a = build(id,part)
            if a.multipart?
                fromMultiParts(attachments,id,part.parts)
            else
                attachments << a
            end
        end
    end

    def self.fromSinglePart(attachments,id,part)
		a = build(id,part)
		attachments << a
    end

    def self.build(id,part)
		cid = ''
		if not part.content_id.nil?
			part.content_id =~ /\<(\S+)\>/
			cid = $1
		else
			cid = ''
		end
		a = Attachment.new( :message_id => id,
							:description => part.content_description,
							:type => part.content_type,
							:content => part.body.raw_source,
							:encoding => part.body.encoding,
							:size => part.body.raw_source.size,
							:charset => part.body.charset,
							:multipart => part.multipart?,
							:cid => cid
							)
		return a
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

    def isHtml?
		@type =~ /^text\/html/
	end

	def isImageAndNotCid?
        @type =~ /^image/ and @cid.size.zero?
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
		begin
        case @encoding
            when /quoted-printable/
                #decoded = @content.gsub(/_/," ").unpack("M").first
                decoded = @content.unpack("M").first
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
        rescue
			@content
        end
    end

    def decode_and_charset
		begin
        decoded = decode

        if not @charset == 'UTF-8'
            @charset.nil? ? charset = $defaults["msg_unknown_charset"] : charset = @charset
            charseted = Iconv.iconv("UTF-8",charset,decoded).first
        else
            charseted = decoded
        end

        charseted
        rescue
			decoded
		end

    end

end



