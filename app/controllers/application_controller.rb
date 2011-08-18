require 'yaml'

class ApplicationController < ActionController::Base

	protect_from_forgery
	before_filter :load_defaults,:current_user,:set_locale
	before_filter :plugins_configuration

    rescue_from ActiveRecord::RecordNotFound do
        logger.custom('record_not_found','exc')
        reset_session
        redirect_to :controller=>'user', :action => 'login'
    end

    ################################# protected section ###########################################

	protected

	def load_defaults
		$defaults ||= YAML::load(File.open(Rails.root.join('config','defaults.yml')))
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
	end

	def check_current_user
		if @current_user.nil?
			session["return_to"] = request.fullpath
            redirect_to :controller => 'user', :action => 'login'
			return false
		end
	end

	def selected_folder
        session[:selected_folder] ? @selected_folder = session[:selected_folder] : @selected_folder = $defaults['mailbox_inbox']
	end

	def get_current_folders
		@folders_shown = @current_user.folders.shown.order("name asc")
		@current_folder = @current_user.folders.find_by_full_name(@selected_folder)
	end

    ##################################### private section ##########################################

    private

    def plugins_configuration
        WillPaginate::ViewHelpers.pagination_options[:previous_label] = t(:previous_page)
        WillPaginate::ViewHelpers.pagination_options[:next_label] = t(:next_page)
    end

end

