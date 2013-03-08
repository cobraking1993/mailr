require 'yaml'

class ApplicationController < ActionController::Base
	
	before_filter :load_settings, :current_user, :set_locale
    
	protected

    def load_settings
        begin
            $defaults ||= YAML::load(File.open(Rails.root.join('config','settings.yml')))
            my_settings = YAML::load(File.open(Rails.root.join('config','my_settings.yml')))
            $defaults.merge!(my_settings) unless my_settings.nil?
        rescue Exception
            flash[:error] = t(:settings_error, :scope => :internal)
            render 'internal/error', :layout => 'simple'
        end
    end

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
		#logger.custom("current_user",@current_user.inspect)
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
        @system_folders = []
        @other_folders = []
        folder_order = $defaults["system_folders_order"]
    	folders_shown = @current_user.folders.shown.order("name asc")
        folders_shown.each do |f|
          if f.isSystem?
            @system_folders[folder_order[f.sys-1].to_i] = f 
          else
            @other_folders << f
          end
        end
        @folders_shown = @system_folders.compact + @other_folders
        unless @selected_folder.nil?
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


end

