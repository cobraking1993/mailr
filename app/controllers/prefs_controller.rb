class PrefsController < ApplicationController

    before_filter :check_current_user,:selected_folder

	before_filter :get_current_folders

	before_filter :get_prefs, :only => [:look,:update_look]

    #theme :theme_resolver

    def update_look
        if params[:prefs]
            @prefs.update_attributes(params[:prefs])
        end
        flash[:success] = t(:were_saved,:scope=>:prefs)
        redirect_to :action => 'look'
    end

    def update_servers

        redirect_to :action => 'servers'
    end

    def update_identity
        if params[:user]
            @current_user.first_name = params[:user][:first_name]
            @current_user.last_name = params[:user][:last_name]
            @current_user.domain = params[:user][:domain]
            if @current_user.valid?
                @current_user.save
                flash[:success] = t(:were_saved,:scope=>:prefs)
                redirect_to :action => 'identity'
            else
                render 'prefs/identity'
            end
        end
    end

    def look

    end

    def identity
    end

    def servers
		@servers = @current_user.servers
    end

    ############################# protected section ##################################

    def get_prefs
        @prefs = @current_user.prefs
    end
end
