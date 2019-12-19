Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    scope "(:province)", province: @province do
      get "/home", to: "static_pages#home"
      get "/list", to: "places#index"
    end
    devise_for :users, skip: %i(registrations sessions passwords)
    as :user do
      post "/users/sign_in", to: "users/sessions#create", as: "user_session"
      delete "/users/sign_out", to: "users/sessions#destroy", as: "destroy_user_session"
    end
    get "/contact", to: "static_pages#contact"
    get "/about", to: "static_pages#about"
    get "/faq", to: "static_pages#faq"
    resources :rates, only: %i(create destroy)
    resources :places, only: %i(new create show update destroy) do
      collection do
        get :show_province_child
        post :add_to_cart
        put :update_cart
        put :update_order
        put :find_shipper
        post :update_status
        post :update_status_order_cancel
        put :shipper_update_order
        post :add_message
      end
      member do
        get :show_order
        post :create_order
        post :express_checkout
      end
    end
    resources :shippers, only: %i(new create update destroy) do
      collection do
        post :update_location
      end
    end
    resources :profiles, only: %i(index) do
      collection do
        patch :update_basic_info
        patch :update_password
        put :update_avatar
        post :create_address
        put :update_address
        delete :delete_address
        post :create_menu_category
        post :create_menu_item
        post :create_menu_option
        delete :delete_menu_category
        delete :delete_menu_item
        delete :delete_menu_option
        put :update_menu_category
        put :update_menu_item
        put :update_menu_option
        post :create_user
        post :confirm_unlock
      end
    end
    get "/admin", to: "admin/dashboard#index"
    get "/profile", to: "admin/dashboard#profile"
    namespace :admin do
      resources :categories, except: :show
      resources :classify_categories, except: :show
      resources :users, except: %i(show) do
        collection do
          post :change_lock_status
        end
      end
      resources :shippers, only: %i(index destroy) do
        collection do
          post :change_lock_status
        end
      end
      resources :places, only: %i(index destroy) do
        collection do
          post :change_lock_status
          post :confirm_proposal
        end
      end
      resources :orders, only: %i(index)
    end
  end
  get "*path", to: "application#page_404"
end
