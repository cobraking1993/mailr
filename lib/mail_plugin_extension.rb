require 'iconv'

module Mail

    class Message

        def decoded_and_charseted
            begin
                if not charset.upcase == 'UTF-8'
                    charset.nil? ? source_charset = $defaults["msg_unknown_charset"] : source_charset = charset
                    charseted = Iconv.iconv("UTF-8",source_charset,decoded).first
                else
                    charseted = decoded
                end
            rescue
                decoded
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

    end

end
