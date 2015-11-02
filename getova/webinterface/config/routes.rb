Rails.application.routes.draw do

  resources :tanet_linkedins
  get '/scrape_linkedin' => 'tanet_linkedins#scrape_person'

  resources :tenders

  resources :complus

  post 'fetch_led_company' => 'complus#fetch_led_company'

  resources :tanets

  resources :individual_formats

  get 'companies/run_clustering' => 'companies#run_clustering'
  get 'companies/search/:search' => 'companies#search'
  get 'companies/clustering_visual' => 'companies#get_json_for_d3'


  get 'tanet' => 'tanets#index'
  get 'tanet/:id' => 'tanets#show'

  resources :companies

  resources :representations

  resources :individuals

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'individuals#index'

  get 'about' => 'about#index'
  get 'search' => 'search#index'

  get 'individuals/:id/:format' => 'individuals#get_format'


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
