require 'yaml'

class ApplicationController < ActionController::Base

	protect_from_forgery

	before_filter :load_defaults,:current_user,:set_locale
	before_filter :plugins_configuration

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

    def prepare_compose_buttons
        @buttons = []
        @buttons << {:text => 'sendout',:scope=>:compose,:image => 'email.png'}
        @buttons << {:text => 'save',:scope=>:compose,:image => 'save.png'}
    end

    def create_message_with_params
        @message = Message.new(params[:message])
#        if params[:message]
#            @message.update_attributes(params[:message])
#        end
        files = Dir.glob(File.join($defaults["msg_upload_dir"],@current_user.username + "*"))
        @attachments = []
        files.each do |f|
            @attachments << {:name => File.basename(f).gsub!(/#{@current_user.username}_/,"") , :size => File.stat(f).size }
        end
    end

    def get_system_folders
        @drafts_folder = @current_user.folders.drafts.first
        @sent_folder = @current_user.folders.sent.first
        @inbox_folder = @current_user.folders.inbox.first
        @trash_folder = @current_user.folders.trash.first
    end

    ##################################### private section ##########################################

    private

    def plugins_configuration
        WillPaginate::ViewHelpers.pagination_options[:previous_label] = t(:previous_page,:scope=>:common)
        WillPaginate::ViewHelpers.pagination_options[:next_label] = t(:next_page,:scope=>:common)
    end

end

