Mailr::Application.routes.draw do

    namespace :prefs do
        post "update_look"
        post "update_identity"
        post "update_servers"
    end
    match "prefs/look" => "prefs#look", :as => :prefs_look
    match "prefs/identity" => "prefs#identity", :as => :prefs_identity
    match "prefs/servers" => "prefs#servers", :as => :prefs_servers

    namespace :contacts do
        post "ops"
        get "export"
    end
    match "/external" => "contacts#external", :as => :external

    resources :contacts

    namespace :folders do
        post "create"
        post "delete"
        post "system"
        post "show_hide"
        post "refresh"
        get "refresh_status"
        get "emptybin"
    end
    match "/folders/index" => 'folders#index', :as => :folders
    match "/folders/select/:id" => 'folders#select', :as => :folders_select

    namespace :internal do
        get "error"
        get "imaperror"
        get "loginfailure"
        get "onlycanlogins"
    end
    match "/internal/about" => 'internal#about' ,:as => :about

    match "/messages_ops/single" => 'messages_ops#single'
    match "/messages_ops/multi" => 'messages_ops#multi'
    match "/messages_ops/sendout_or_save" => 'messages_ops#sendout_or_save' ,:as =>:sendout_or_save
    match "/messages_ops/upload" => 'messages_ops#upload',:as => :upload
    match "/messages_ops/edit/:id" => 'messages_ops#edit', :as => :edit
    match "/messages_ops/composed" => 'messages_ops#composed', :as => :composed

	root :to => "messages#index"

    match "/messages/index" => 'messages#index', :as => :messages
    match "/messages/compose" => 'messages#compose', :as => :compose
    match "/messages/compose/:cid" => 'messages#compose', :as => :compose_contact
    match "/messages/show/:id" => 'messages#show'
    match "/messages/html_body/:id" => 'messages#html_body' , :as => :html_body
    match "/messages/attachment/:id/:idx" => 'messages#attachment', :as => :attachment_download

    namespace :user do
        get "logout"
        post "authenticate"
        post "create"
        get "login"
        get "setup"
        get "unknown"
    end
    match "/user/setup/:login" => 'user#setup'

	themes_for_rails

    #match '*a', :to => 'internal#not_found'
    #match ':controller(/:action(/:id(.:format)))'
end
