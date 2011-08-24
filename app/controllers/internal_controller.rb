class InternalController < ApplicationController

	theme :theme_resolver
	layout "simple"

	def error

	end

	def imaperror
		@title = t(:imap_error)
		@error = params[:error] || t(:unspecified_error)
		logger.error "!!! InternalControllerImapError: " + @error
        render 'error'
	end

	def page_not_found
        @title = t(:page_not_found)
		@error = t(:page_not_found)
		logger.error "!!! InternalControllerError: " + @error
		render 'error'
    end

	def loginfailure
        reset_session
        flash[:error] = t(:login_failure,:scope=>:user)
        @current_user = nil
        redirect_to :controller=>'user', :action => 'login'
	end

	def onlycanlogins
        reset_session
        flash[:error] = t(:only_can_logins,:scope=>:user)
        @current_user = nil
        redirect_to :controller=>'user', :action => 'login'
	end

end
