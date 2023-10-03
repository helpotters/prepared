Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "words#index"

  concern :paginatable do
    get "(page/:page)", action: :index, on: :collection, as: ""
  end

  # get "/words", to: "words#index"
  # get "/words/:id", to: "words#show"
  resources :words, concerns: :paginatable do
    resources :definitions
  end

end
