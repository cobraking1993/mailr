require 'yaml'

class ApplicationController < ActionController::Base

	protect_from_forgery

	before_filter :load_defaults,:current_user,:set_locale

	before_filter :plugins_configuration

#    rescue_from ActiveRecord::RecordNotFound do
#        logger.custom('record_not_found','exc')
#        reset_session
#        redirect_to :controller=>'user', :action => 'login'
#    end

    def load_defaults
		$defaults ||= YAML::load(File.open(Rails.root.join('config','defaults.yml')))
	end

    ################################# protected section ###########################################

	protected

	def theme_resolver
		if @current_user.nil?
			$defaults['theme']
		else
			@current_user.prefs.theme || $defaults['theme']
		end
	end

	def set_locale
		if @current_user.nil?
			I18n.locale = $defaults['locale'] || I18n.default_locale
		else
			I18n.locale = @current_user.prefs.locale.to_sym || I18n.default_locale
		end
	end

	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	def check_current_user
		if @current_user.nil?
			session["return_to"] = request.fullpath
            redirect_to :controller => 'user', :action => 'login'
			return false
		end
	end

	def selected_folder
        if session[:selected_folder]
            @selected_folder = session[:selected_folder]
        else
            folder = @current_user.folders.inbox.first
            if not folder.nil?
                @selected_folder = folder.full_name
            end
        end
	end

	def get_current_folders
		@folders_shown = @current_user.folders.shown.order("name asc")
		if not @selected_folder.nil?
            @current_folder = @current_user.folders.find_by_full_name(@selected_folder)
        end
	end

	def self.decode_quoted(text,unknown_charset = $defaults["msg_unknown_charset"])
        begin
            if text.match(/\=\?.+\?\w\?.+\?\=/).nil?
                after = Iconv.conv('UTF-8',unknown_charset,text)
                #after = text
            else

# FIXME support multiple showing of =?xxx?=


					after = text
					match = text.match(/\=\?.+\?\w\?.+\?\=/).to_s
					f = match.split(/\?/)
					case f[2].downcase
						when 'q':
							replace = f[3].gsub(/_/," ").unpack("M").first
						when 'b':
							replace = f[3].gsub(/_/," ").unpack("m").first
						else
							replace = match
					end
					match.gsub!(/\?/,'\?')
					match.gsub!(/\)/,'\)')
					after = text.gsub(/#{match}/,replace)

                if f[1].downcase != 'utf-8'
                    after = Iconv.conv('UTF-8',f[1],after)
                end

            end
            #logger.custom('after',after)
            return after
        rescue Exception => e
            logger.error("Class Message: #{e.to_s}: T: #{text} M: #{match} R: #{replace} A: #{after}")
            return text
        end
    end

    def prepare_compose_buttons
        @buttons = []
        @buttons << {:text => 'send',:image => 'tick.png'}
        @buttons << {:text => 'save_as_draft',:image => 'tick.png'}
    end

    ##################################### protected section ########################################

    protected

    def get_system_folders
        @drafts_folder = @current_user.folders.drafts.first
        @sent_folder = @current_user.folders.sent.first
        @inbox_folder = @current_user.folders.inbox.first
        @trash_folder = @current_user.folders.trash.first
    end

    ##################################### private section ##########################################

    private

    def plugins_configuration
        WillPaginate::ViewHelpers.pagination_options[:previous_label] = t(:previous_page)
        WillPaginate::ViewHelpers.pagination_options[:next_label] = t(:next_page)
    end

end

