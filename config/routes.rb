Mailr::Application.routes.draw do

  #match "prefs/index" => "prefs#index", :as => :prefs

  post "prefs/update_look"
  post "prefs/update_identity"
  post "prefs/update_servers"

  match "prefs/look" => "prefs#look", :as => :prefs_look
  match "prefs/identity" => "prefs#identity", :as => :prefs_identity
  match "prefs/servers" => "prefs#servers", :as => :prefs_servers

  resources :contacts
  post "contacts/ops"


  #resources :folders
  match "folders/index" => 'folders#index', :as => :folders
  post "folders/create"
  post "folders/delete"
  post "folders/system"
  post "folders/show_hide"
  post "folders/refresh"
  get "folders/refresh_status"
  post "folders/refresh"
  match "folders/select/:id" => 'folders#select', :as => :folders_select
  get "folders/emptybin"

    get "internal/error"
    get "internal/imaperror"
    get "internal/loginfailure"
    get "internal/onlycanlogins"

    match "messages_ops/single" => 'messages_ops#single'
    match "messages_ops/multi" => 'messages_ops#multi'
    match "messages_ops/sendout_or_save" => 'messages_ops#sendout_or_save' ,:as =>:sendout_or_save
    match "messages_ops/upload" => 'messages_ops#upload',:as => :upload

	root :to => "messages#index"
	match "messages/index" => 'messages#index', :as => :messages
	match "messages/compose" => 'messages#compose', :as => :compose
	#get "messages/refresh_status"
	#get "messages/emptybin"
	#match "messages/select/:id" => 'messages#select', :as => :messages_select
	get "messages/index"
	#match 'messages/folder/:id' => 'messages#folder', :as => :messages_folder
	#post "messages/ops"
	#post "messages/msgops"

	#match "messages/edit/:id" => 'messages#edit' ,:as => :messages_edit
	#match "messages/reply/:id" => 'messages#reply'

	match "messages/show/:id" => 'messages#show'
	#match "messages/body/:id/:idx" => 'messages#body' , :as => :messages_part_body
	match "messages/html_body/:id" => 'messages#html_body' , :as => :messages_html_body
	match "messages/attachment/:id/:idx" => 'messages#attachment', :as => :messages_attachment_download

	get "user/logout"
	post "user/authenticate"
	post "user/create"
	get "user/login"
	get "user/setup"
	match 'user/setup/:id' => 'user#setup'
	get "user/unknown"

	themes_for_rails

	match '*a', :to => 'internal#not_found'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
