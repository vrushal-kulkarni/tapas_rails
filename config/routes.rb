TapasRails::Application.routes.draw do

  # This line mounts Forem's routes at /forums by default.
  # This means, any requests to the /forums URL of your application will go to Forem::ForumsController#index.
  # If you would like to change where this extension is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Forem relies on it being the default of "forem"
  mount Forem::Engine, :at => '/forums'

  devise_for :users

  # root to: "catalog#index"
  root to: "pages#show", id: 'home'
  blacklight_for :catalog
  # Blacklight.add_routes(self)
  # HydraHead.add_routes(self)
  # At some point we'll want all this, but I'm going to disable these routes
  # until we're ready to migrate to 100% Hydra-Head usage for tapas.
  # root :to => "view_packages#index"
  # blacklight_for :catalog
  # devise_for :users

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Show resque admin in development environment
  resque_web_constraint = lambda do |request|
    Rails.env == "development"
  end

  # constraints resque_web_constraint do
  mount Resque::Server, at: "/resque"
  # end

  get 'browse' => 'catalog#browse'
  
  # Communities
  resources :communities
  get 'communities/:did' => 'communities#show'
  get 'communities/:did/edit' => 'communities#edit'
  post "communities/:did" => "communities#upsert"
  get 'communities' => 'communities#index'
  #get '/catalog/:id' => 'communities#show'
  # delete "communities/:did" => "communities#destroy"

  # Collections
  resources :collections
  get 'collections/:did' => 'collections#show'
  post "collections/:did" => "collections#upsert"
  get 'collections/:did/edit' => 'collections#edit'
  get 'collections' => 'collections#index'


  # delete "collections/:did" => "collections#destroy"

  # CoreFiles
  resources :core_files
  get 'core_files/:did/edit' => 'core_files#edit'
  get 'core_files' => 'core_files#index'

  get 'files/:did/mods' => 'core_files#mods'
  get 'files/:did/tei' => 'core_files#tei'
  get 'files/:did' => 'core_files#api_show'
  get 'core_files/:did' => 'core_files#show'
  put 'core_files/:did/reading_interfaces' => 'core_files#rebuild_reading_interfaces'
  post 'core_files/:id' => 'core_files#update'
  post 'files/:did' => 'core_files#upsert'
  # delete "files/:did" => "core_files#destroy"

  get 'files/:did/html/:view_package' => 'core_files#view_package_html'

  resources :downloads, :only => 'show'

  namespace :api do
    get 'communities/:did' => 'communities#api_show'
    get 'collections/:did' => 'collections#api_show'
    get 'core_files/:did' => 'core_files#api_show'
  end
  resources :view_packages
  get 'api/view_packages' => 'view_packages#api_index'

  get '/admin' => 'admin#index'
  resources :pages

  get 'my_tapas' => 'users#my_tapas'
  get 'my_projects' => 'users#my_projects'

  mount Bootsy::Engine => '/bootsy', as: 'bootsy'

  match '/:id' => 'pages#show', via: 'get' #must go at end since it matches on everything

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
