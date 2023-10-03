Rails.application.routes.draw do
  root "words#index"

  concern :paginatable do
    get "(page/:page)", action: :index, on: :collection, as: ""
  end

  # get "/words", to: "words#index"
  # get "/words/:id", to: "words#show"
  resources :words, concerns: :paginatable do
    resources :definitions
  end

  namespace :api do
    resources :words, concerns: :paginatable, :defaults => { :format => "json" }, :only => [:create, :index, :show]
  end
end
