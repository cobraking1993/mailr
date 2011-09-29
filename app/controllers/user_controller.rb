class UserController < ApplicationController

	theme :theme_resolver
	layout "simple"

	def login
	end

	def logout
		reset_session
		flash[:notice] = t(:logged_out,:scope=>:user)
		redirect_to :action => "login"
	end

	def authenticate

        if not $defaults["only_can_logins"].nil?
            if not $defaults["only_can_logins"].include?(params[:user][:login])
                redirect_to :controller => 'internal', :action => 'onlycanlogins'
                return false
            end
        end

		user = User.find_by_login(params[:user][:login])
		if user.nil?
			redirect_to :action => 'unknown' ,:login=> params[:user][:login]
		else
            session[:user_id] = user.id
			user.set_cached_password(session,params[:user][:password])

			if session["return_to"]
                redirect_to(session["return_to"])
				session["return_to"] = nil
			else
				redirect_to :controller=> 'messages', :action=> 'index'
			end

		end
	end

	def loginfailure
	end

	def setup
		@user = User.new
		@server = Server.new
	end

	def unknown
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
			Server.create_defaults(@user)
			flash[:notice] = t(:setup_done,:scope=>:user)
			redirect_to :action => 'login'
		else
			render "setup"
		end
	end

end
