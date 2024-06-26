spree_path = Rails.application.routes.url_helpers.try(:spree_path, trailing_slash: true) || '/'

Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :promotions, only: [:show]

      resources :customer_returns, only: [:index]
      resources :reimbursements, only: [:index]

      resources :products do
        resources :images
        resources :variants
        resources :product_properties
      end

      concern :order_routes do
        member do
          put :approve
          put :cancel
          put :empty
          put :apply_coupon_code
        end

        resources :line_items
        resources :payments do
          member do
            put :authorize
            put :capture
            put :purchase
            put :void
            put :credit
          end
        end

        resources :addresses, only: [:show, :update]

        resources :return_authorizations do
          member do
            put :add
            put :cancel
            put :receive
          end
        end
      end

      resources :checkouts, only: [:update], concerns: :order_routes do
        member do
          put :next
          put :advance
        end
      end

      resources :variants do
        resources :images
      end

      resources :option_types do
        resources :option_values
      end
      resources :option_values

      resources :option_values, only: :index

      get '/orders/mine', to: 'orders#mine', as: 'my_orders'
      get '/orders/current', to: 'orders#current', as: 'current_order'

      resources :orders, concerns: :order_routes do
        put :remove_coupon_code, on: :member
      end

      resources :zones
      resources :countries, only: [:index, :show] do
        resources :states, only: [:index, :show]
      end

      resources :shipments, only: [:create, :update] do
        collection do
          post 'transfer_to_location'
          post 'transfer_to_shipment'
          get :mine
        end

        member do
          put :ready
          put :ship
          put :add
          put :remove
        end
      end
      resources :states, only: [:index, :show]

      resources :taxonomies do
        member do
          get :jstree
        end
        resources :taxons do
          member do
            get :jstree
          end
        end
      end

      resources :taxons, only: [:index]

      resources :inventory_units, only: [:show, :update]

      resources :users do
        resources :credit_cards, only: [:index]
      end

      resources :properties
      resources :stock_locations do
        resources :stock_movements
        resources :stock_items
      end

      resources :stock_items, only: [:index, :update, :destroy]
      resources :stores

      put '/classifications', to: 'classifications#update', as: :classifications
      get '/taxons/products', to: 'taxons#products', as: :taxon_products
    end

    match 'v:api/*path', to: redirect { |params, request|
      format = ".#{params[:format]}" unless params[:format].blank?
      query  = "?#{request.query_string}" unless request.query_string.blank?

      if request.path == "#{spree_path}api/v1/#{params[:path]}#{format}#{query}"
        "#{spree_path}"
      else
        "#{spree_path}api/v1/#{params[:path]}#{format}#{query}"
      end
    }, via: [:get, :post, :put, :patch, :delete]
  
    match '*path', to: redirect { |params, request|
      format = ".#{params[:format]}" unless params[:format].blank?
      query  = "?#{request.query_string}" unless request.query_string.blank?

      if request.path == "#{spree_path}api/v1/#{params[:path]}#{format}#{query}"
        "#{spree_path}"
      else
        "#{spree_path}api/v1/#{params[:path]}#{format}#{query}"
      end
    }, via: [:get, :post, :put, :patch, :delete]
  end
end
