require 'iconv'

module Mail

	class Message
    attr_accessor :idx,:parent_id
			

        def decoded_and_charseted
					decoded
            #begin
                #if not charset.upcase == 'UTF-8'
                    #charset.nil? ? source_charset = $defaults["msg_unknown_charset"] : source_charset = charset
                    #charseted = Iconv.iconv("UTF-8",source_charset,decoded).first
                #else
                    #charseted = decoded
                #end
            #rescue
                #decoded
            #end
        end
        
        def isImage?
            not (content_type =~ /^image/).nil?
        end

        def isText?
            not (content_type =~ /^text\/plain/).nil?
        end

        def isHtml?
            not (content_type =~ /^text\/html/).nil?
        end

        def getSize
            body.raw_source.size
        end
        
        def filename_charseted
            begin
                if content_type =~ /\=\?([\w\-]+)\?/
                    source_charset = $1
                    if source_charset.upcase == 'UTF-8'
                        return filename
                    end
                else
                    source_charset = $defaults["msg_unknown_charset"]
                end
                Iconv.iconv("UTF-8",source_charset,filename).first
            rescue
                filename
            end
        end

    end

    class Part

        attr_accessor :idx,:parent_id

        def isImage?
            not (content_type =~ /^image/).nil?
        end

        def isText?
            not (content_type =~ /^text\/plain/).nil?
        end

        def isHtml?
            not (content_type =~ /^text\/html/).nil?
        end

        def getSize
            body.raw_source.size
        end

        def decoded_and_charseted
					decoded
            #begin
                #if not charset.upcase == 'UTF-8'
                    #charset.nil? ? source_charset = $defaults["msg_unknown_charset"] : source_charset = charset
                    #charseted = Iconv.iconv("UTF-8",source_charset,decoded).first
                #else
                    #charseted = decoded
                #end
            #rescue
                #decoded
            #end
        end


    end

    class Field
        def charseted
            begin
                if value =~ /\=\?([\w\-]+)\?/
                    source_charset = $1
                    if source_charset.upcase == 'UTF-8'
                        return decoded
                    end
                else
                    source_charset = $defaults["msg_unknown_charset"]
                end
                Iconv.iconv("UTF-8",source_charset,decoded).first
            rescue
                decoded
            end
        end
    end

    class Address
        def charseted
            begin
                if value =~ /\=\?([\w\-]+)\?/
                    source_charset = $1
                    if source_charset.upcase == 'UTF-8'
                        return decoded
                    end
                else
                    source_charset = $defaults["msg_unknown_charset"]
                end
                Iconv.iconv("UTF-8",source_charset,decoded).first
            rescue
                decoded
            end
        end
    end

    #class Part
        #def filename_charseted
            #begin
                #if content_type =~ /\=\?([\w\-]+)\?/
                    #source_charset = $1
                    #if source_charset.upcase == 'UTF-8'
                        #return filename
                    #end
                #else
                    #source_charset = $defaults["msg_unknown_charset"]
                #end
                #Iconv.iconv("UTF-8",source_charset,filename).first
            #rescue
                #filename
            #end
        #end
    #end

end
