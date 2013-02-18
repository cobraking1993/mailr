class UserController < ApplicationController

	#theme :theme_resolver
	layout "simple"

	def login
		# database empty redirect to setup screen
		users = User.all
		if users.count.zero?
			redirect_to :controller => 'user', :action => 'setup'
			return false
		end
	end

	def logout
		reset_session
		flash[:success] = t(:logged_out,:scope=>:user)
		redirect_to :action => "login"
	end

	def authenticate
	
		# check if user can use application
		if not $defaults["only_can_logins"].nil?
				if not $defaults["only_can_logins"].include?(params[:user][:login])
						flash[:error] = t(:only_can_logins,:scope=>:user)
						redirect_to :action => 'login'
						return false
				end
		end

		user = User.find_by_login(params[:user][:login])
		if user.nil?

			logger.info "XXXXXX"
			
			flash[:error] = t(:login_failure,:scope=>:user)
			redirect_to :action => 'login'
			return false
			
		else
      
      session[:user_id] = user.id
			user.set_cached_password(session,params[:user][:password])

			if session["return_to"]
				redirect = session["return_to"]
				session["return_to"] = nil
        redirect_to(redirect)
			else
				redirect_to :controller=> 'messages', :action=> 'index'
			end

		end
	end

	#def loginfailure
	#end

	def setup
		users = User.all
		if !users.count.zero?
			redirect_to :controller => 'internal', :action => 'allready_configured'
			return false
		end
		@user = User.new
		@server = Server.new
	end

	def create

		@user = User.new
		@user.login = params[:user][:login]
		@user.first_name = params[:user][:first_name]
		@user.last_name = params[:user][:last_name]

    @server = Server.new
		@server.name = params[:server][:name]

		if @user.valid? and @server.valid?
			@user.save
			#@server.user_id = @user.id
			#@server.save
			Prefs.create_default(@user)
			Server.create_server(@user,@server.name)
			flash[:success] = t(:setup_done,:scope=>:user)
			redirect_to :action => 'login'
		else
			render "setup"
		end
	end

end
