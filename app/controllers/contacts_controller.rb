class ContactsController < ApplicationController

	before_filter :check_current_user,:selected_folder, :get_current_folders

	before_filter :get_contacts, :only => [:index]

	theme :theme_resolver

    def index

    end

    def ops
        if !params["cids"]
            flash[:warning] = t(:no_selected,:scope=>:contact)
        else
            if params["delete"]
                params["cids"].each do |id|
                    @current_user.contacts.find_by_id(id).destroy
                end
            elsif params["compose"]
                redirect_to :controller=>'messages',:action=>'compose',:cids=>params["cids"]
                return
            end
        end
        redirect_to(contacts_path)
    end

    #problem http://binary10ve.blogspot.com/2011/05/migrating-to-rails-3-got-stuck-with.html
    #def destroy
    #    @current_user.contacts.find(params[:id]).destroy
    #    redirect_to(contacts_path)
    #end

    def new
        @contact = Contact.new
    end

    def edit
        @contact = @current_user.contacts.find(params[:id])
        render 'edit'
    end

    def create
        @contact = @current_user.contacts.build(params[:contact])
        if @contact.valid?
            @contact.save
            flash[:notice] = t(:was_created,:scope=>:contact)
            redirect_to(contacts_path)
        else
            render 'new'
        end
    end

    def update
        @contact = @current_user.contacts.find(params[:id])
        if @contact.update_attributes(params[:contact])
            redirect_to(contacts_path)
        else
            render 'edit'
        end
    end

    ####################################### private section ##################################

    private

    def get_contacts
        @contacts = Contact.getPageForUser(@current_user,params[:page],params[:sort_field],params[:sort_dir])
    end

end
